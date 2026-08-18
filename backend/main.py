import os
import json
from dotenv import load_dotenv
from typing import Optional, List
from fastapi import FastAPI, File, UploadFile, Form, HTTPException, Request, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from supabase import create_client, Client
import stripe

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=False,
    allow_methods=['*'],
    allow_headers=['*'],
)

load_dotenv()

STRIPE_SECRET_KEY = os.getenv("STRIPE_SECRET_KEY")
STRIPE_PUBLISHABLE_KEY = os.getenv("STRIPE_PUBLISHABLE_KEY")
STRIPE_WEBHOOK_SECRET = os.getenv("STRIPE_WEBHOOK_SECRET", "")

stripe.api_key = STRIPE_SECRET_KEY

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

BUCKET_NAME = "products"
PRODUCTS_TABLE = "products"
ORDERS_TABLE = "orders"

class CartItem(BaseModel):
    product_id: int
    quantity: int = 1

class PaymentIntentRequest(BaseModel):
    userId: str
    items: List[CartItem]
    currency: str = "pkr"

@app.get("/api/orders/{uid}")
async def get_orders(uid: str):
    try:
        response = supabase.table(ORDERS_TABLE).select("created_at, details").eq('userId', uid).order("created_at", desc=True).execute()

        return {
            "status": "success",
            "count": len(response.data),
            "data": response.data
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Failed to retrieve data: {str(e)}"
        }


@app.post("/api/create-payment-intent")
async def create_payment_intent(payload: PaymentIntentRequest):
    try:
        total_amount_paisa = 0

        cart_metadata = {}

        for item in payload.items:
            product_query = supabase.table(PRODUCTS_TABLE).select("name, price").eq("id", item.product_id).execute()
            if not product_query.data:
                raise HTTPException(status_code=404, detail=f"Product ID {item.product_id} not found")

            product = product_query.data[0]
            price = product["price"]
            name = product["name"]
            total_amount_paisa += int(price * 100) * item.quantity

            cart_metadata[str(item.product_id)] = {
                "name": name,
                "price": price,
                "quantity": item.quantity
            }

        if total_amount_paisa <= 0:
            raise HTTPException(status_code=400, detail="Invalid payment amount")

        serialized_cart = json.dumps(cart_metadata)

        intent = stripe.PaymentIntent.create(
            amount=total_amount_paisa,
            currency=payload.currency.lower(),
            automatic_payment_methods={"enabled": True},
            metadata={
                "user_id": payload.userId,
                "cart_details": serialized_cart,
                "item_count": len(payload.items)
            }
        )

        return {
            "status": "success",
            "clientSecret": intent.client_secret,
            "publishableKey": STRIPE_PUBLISHABLE_KEY,
            "amount": total_amount_paisa,
            "currency": payload.currency
        }

    except stripe.error.StripeError as e:
        return {"status": "error", "message": f"Stripe error: {str(e)}"}
    except Exception as e:
        return {"status": "error", "message": f"Internal server error: {str(e)}"}

@app.post("/api/stripe-webhook")
async def stripe_webhook(request: Request, stripe_signature: Optional[str] = Header(None)):
    event = None

    try:
        if STRIPE_WEBHOOK_SECRET and stripe_signature:
            payload = await request.body()
            try:
                event = stripe.Webhook.construct_event(
                    payload, stripe_signature, STRIPE_WEBHOOK_SECRET
            )
            except stripe.error.SignatureVerificationError as e:
                print(f"Webhook Signature Verification Failed: {str(e)}")
                raise HTTPException(status_code=400, detail="Invalid signature")
        else:
            try:
                event_data = await request.json()
                event = event_data
            except Exception as json_error:
                print(f"Error parsing Webhook JSON: {json_error}")
                raise HTTPException(status_code=400, detail="Invalid JSON payload")

        if event and event["type"] == "payment_intent.succeeded":
            payment_intent = event["data"]["object"]
            print(f"Payment Intent {payment_intent['id']} succeeded for amount {payment_intent['amount']}")

            metadata = payment_intent.metadata
            user_id_from_meta = metadata["user_id"] if "user_id" in metadata else None
            serialized_cart_from_meta = metadata["cart_details"] if "cart_details" in metadata else None

            if not user_id_from_meta or not serialized_cart_from_meta:
                print("Webhook Error: Missing user_id or cart_details in PaymentIntent metadata.")
                return {"status": "error", "message": "Missing metadata"}

            try:
                supabase.table(ORDERS_TABLE).insert({
                    "userId": user_id_from_meta,
                    "details": serialized_cart_from_meta
                }).execute()

                print(f"Transaction History Updated for User: {user_id_from_meta}")

            except Exception as db_e:
                print(f"Supabase DB Insert Error: {str(db_e)}")

        return {"status": "success"}

    except stripe.error.SignatureVerificationError as e:
        print(f"Webhook Signature Verification Failed: {str(e)}")
        raise HTTPException(status_code=400, detail="Invalid signature")
    except HTTPException as http_e:
        raise http_e
    except Exception as e:
        print(f"General Webhook Error: {str(e)}")
        raise HTTPException(status_code=400, detail=f"Webhook error: {str(e)}")
    
@app.post("/api/upload")
async def upload_item(
    name: str = Form(...),
    desc: str = Form(...),
    price: float = Form(...),
    category: str = Form(...),
    image: UploadFile = File(...)
):
    try:
        file_bytes = await image.read()

        import time
        clean_filename = f"{int(time.time())}_{image.filename}"
        storage_path = f"images/{clean_filename}"

        supabase.storage.from_(BUCKET_NAME).upload(
            path = storage_path,
            file = file_bytes,
            file_options = {"content-type": image.content_type}
        )

        public_url = supabase.storage.from_(BUCKET_NAME).get_public_url(storage_path)

        db_response = supabase.table(PRODUCTS_TABLE).insert({
            "name": name,
            "description": desc,
            "price": price,
            "category": category,
            "image_url": public_url
        }).execute()

        print(f"Item received: {name}, Price: {price}, Desc: {desc}, Category: {category}")
        print(f"Supabase Upload Success, Public URL: {public_url}")

        return {
            "status": "Success",
            "message": "Item details and image uploaded successfully!",
            "data": db_response.data
        }

    except Exception as e:
        return {
            "status": "error",
            "message": f"An error occurred: {str(e)}"
            }

@app.get("/api/products")
async def get_products():
    try:
        response = supabase.table(PRODUCTS_TABLE).select("*").order("created_at", desc=True).execute()

        return {
            "status": "success",
            "count": len(response.data),
            "data": response.data
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Failed to retrieve data: {str(e)}"
        }
    
@app.delete("/api/products/{product_id}")
async def delete_product(product_id: int):
    try:
        item_query = supabase.table(PRODUCTS_TABLE).select("image_url").eq("id", product_id).execute()

        if not item_query.data:
            raise HTTPException(status_code=404, detail="Product not found.")

        image_url = item_query.data[0]["image_url"]

        path_identifier = f"{BUCKET_NAME}/"
        if path_identifier in image_url:
            storage_path = image_url.split(path_identifier)[-1]
            supabase.storage.from_(BUCKET_NAME).remove([storage_path])

        db_response = supabase.table("products").delete().eq("id", product_id).execute()

        return {
            "status": "success",
            "message": f"Product with ID {product_id} and its associated image were deleted.",
            "data": db_response.data
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Deletion failed: {str(e)}"
        }

@app.put("/api/products/{product_id}")
async def update_product(
    product_id: int,
    name: str = Form(...),
    desc: str = Form(...),
    price: float = Form(...),
    category: str = Form(...),
    image: Optional[UploadFile] = File(None)
):
    try:
        print("Starting Update Product Function")
        current_item = supabase.table(PRODUCTS_TABLE).select("*").eq("id", product_id).execute()
        if not current_item.data:
            return {
                "status": "error",
                "message": "Product not found"
            }

        update_data = {
            "name": name,
            "description": desc,
            "price": price,
            "category": category,
        }

        if image:
            old_image_url = current_item.data[0]["image_url"]
            path_identifier = f"{BUCKET_NAME}/"
            if path_identifier in old_image_url:
                old_storage_path = old_image_url.split(path_identifier)[-1]
                try:
                    supabase.storage.from_(BUCKET_NAME).remove([old_storage_path])
                except Exception as storage_err:
                    print(f"Failed to delete old image asset: {storage_err}")

            file_bytes = await image.read()
            import time
            clean_filename = f"{int(time.time())}_{image.filename}"
            new_storage_path = f"images/{clean_filename}"

            supabase.storage.from_(BUCKET_NAME).upload(
                path = new_storage_path,
                file = file_bytes,
                file_options = {"content-type": image.content_type}
            )

            new_public_url = supabase.storage.from_(BUCKET_NAME).get_public_url(new_storage_path)
            update_data["image_url"] = new_public_url

        print("Before DB Response")
        db_response = supabase.table(PRODUCTS_TABLE).update(update_data).eq("id", product_id).execute()
        print(f"DB Response: {db_response}")
        return {
            "status": "success",
            "message": "Product updated successfully!",
            "data": db_response.data
        }

    except Exception as e:
        return {
            "status": "error",
            "message": f"Update failed: {str(e)}"
        }