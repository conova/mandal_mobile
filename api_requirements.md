# API Requirements Document (Mandal Mobile App)

Энэхүү баримт бичигт Mandal Mobile аппликэйшний бүхий л мэдээллийг серверээс татах болон илгээхэд шаардлагатай API жагсаалт, тэдгээрийн Request (хүсэлт) болон Response (хариу) бүтцийг апп-ын боломжит дэлгэцүүд дээр суурилан тодорхойлсон болно.

---

## 1. Authentication (Нэвтрэх болон Бүртгэл)

### 1.1. Нэвтрэх (Login)
*   **Endpoint URL:** `POST /api/v1/auth/login`
*   **Тайлбар:** Хэрэглэгч утасны дугаар эсвэл имэйл болон нууц үгээр нэвтрэх.
*   **Request:**
    ```json
    {
      "login_id": "99887766",
      "password": "Password123!"
    }
    ```
*   **Response:**
    ```json
    {
      "status": "success",
      "data": {
        "access_token": "eyJhbGciOiJIUzI1NiIsInR...",
        "refresh_token": "def502005086ee6e...",
        "user_id": "usr_12345",
        "requires_otp": false
      }
    }
    ```

### 1.2. OTP Илгээх (Send OTP)
*   **Endpoint URL:** `POST /api/v1/auth/otp/send`
*   **Тайлбар:** Нэвтрэх, бүртгүүлэх эсвэл нууц үг сэргээхэд зориулан баталгаажуулах код илгээх.
*   **Request:**
    ```json
    {
      "phone": "99887766",
      "purpose": "login" // login, register, forgot_password
    }
    ```
*   **Response:**
    ```json
    {
      "status": "success",
      "message": "OTP код амжилттай илгээгдлээ"
    }
    ```

### 1.3. OTP Баталгаажуулах (Verify OTP)
*   **Endpoint URL:** `POST /api/v1/auth/otp/verify`
*   **Request:**
    ```json
    {
      "phone": "99887766",
      "otp_code": "1234",
      "purpose": "login"
    }
    ```
*   **Response:**
    ```json
    {
      "status": "success",
      "data": {
        "verification_token": "abc_123_xyz" // Энэ токенийг дараагийн алхамд ашиглаж болно
      }
    }
    ```

### 1.4. Бүртгүүлэх (Register)
*   **Endpoint URL:** `POST /api/v1/auth/register`
*   **Request:**
    ```json
    {
      "verification_token": "abc_123_xyz",
      "phone": "99887766",
      "password": "Password123!",
      "bank_account": "5000123456" // Шаардлагатай бусад мэдээллүүд
    }
    ```
*   **Response:**
    ```json
    {
      "status": "success",
      "data": {
        "user_id": "usr_new_123",
        "access_token": "eyJhbG...",
        "refresh_token": "def50..."
      }
    }
    ```

---

## 2. User & Onboarding (Хэрэглэгч болон Баталгаажуулалт)

### 2.1. Хэрэглэгчийн мэдээлэл авах (Get Profile)
*   **Endpoint URL:** `GET /api/v1/users/profile`
*   **Хавсралт:** Header: `Authorization: Bearer {token}`
*   **Response:**
    ```json
    {
      "status": "success",
      "data": {
        "user_id": "usr_12345",
        "phone": "99887766",
        "first_name": "Бат",
        "last_name": "Дорж",
        "is_verified": true,
        "email": "bat@example.com",
        "avatar_url": "https://..."
      }
    }
    ```

### 2.2. Бичиг баримт баталгаажуулах (Document Verification / KYC)
*   **Endpoint URL:** `POST /api/v1/users/verify-document`
*   **Тайлбар:** Иргэний үнэмлэх болон селфи зураг илгээх. (Multipart/form-data)
*   **Request:**
    ```json
    // FormData content
    {
      "front_image": (File Object),
      "back_image": (File Object),
      "selfie_image": (File Object)
    }
    ```
*   **Response:**
    ```json
    {
      "status": "success",
      "message": "Бичиг баримт амжилттай илгээгдлээ. Шалгагдаж байна.",
      "data": {
        "verification_status": "pending"
      }
    }
    ```

### 2.3. ДАН системээр баталгаажуулах (DAN Verification)
*   **Endpoint URL:** `POST /api/v1/users/verify-dan`
*   **Request:**
    ```json
    {
      "dan_code": "code_from_dan_system"
    }
    ```
*   **Response:**
    ```json
    {
      "status": "success",
      "data": {
        "first_name": "Бат",
        "last_name": "Дорж",
        "register_no": "УУ99001122"
      }
    }
    ```

### 2.4. PEP Асуулга (Politically Exposed Person)
*   **Endpoint URL:** `POST /api/v1/users/pep-status`
*   **Request:**
    ```json
    {
      "is_pep": false,
      "answers": {
        "q1_governmental_related": false,
        "q2_family_pep": false
      }
    }
    ```
*   **Response:**
    ```json
    {
      "status": "success"
    }
    ```

---

## 3. Wallet & Bank Accounts (Хэтэвч болон Данс)

### 3.1. Холбосон дансууд (Bank Accounts)
*   **Endpoint URL:** `GET /api/v1/wallet/accounts`
*   **Response:**
    ```json
    {
      "status": "success",
      "data": [
        {
          "account_id": "acc_001",
          "bank_name": "Хаан банк",
          "account_number": "5000112233",
          "account_name": "Бат",
          "is_primary": true
        }
      ]
    }
    ```

### 3.2. Орлого хийх / Нэхэмжлэх үүсгэх (Deposit / QPay)
*   **Endpoint URL:** `POST /api/v1/wallet/deposit`
*   **Request:**
    ```json
    {
      "amount": 100000,
      "method": "qpay" // эсвэл bank_transfer
    }
    ```
*   **Response:**
    ```json
    {
      "status": "success",
      "data": {
        "transaction_id": "txn_123",
        "qpay_url": "https://qpay.mn/...",
        "qpay_qr_code": "base64_image_string"
      }
    }
    ```

### 3.3. Зарлага гаргах (Withdraw)
*   **Endpoint URL:** `POST /api/v1/wallet/withdraw`
*   **Request:**
    ```json
    {
      "amount": 50000,
      "account_id": "acc_001", // Хүлээн авах банкны дансны ID
      "pin": "1234"
    }
    ```
*   **Response:**
    ```json
    {
      "status": "success",
      "message": "Зарлагын хүсэлт амжилттай бүртгэгдлээ."
    }
    ```

### 3.4. Гүйлгээний түүх (Transaction History)
*   **Endpoint URL:** `GET /api/v1/wallet/transactions`
*   **Response:**
    ```json
    {
      "status": "success",
      "data": [
        {
          "id": "txn_001",
          "type": "deposit", // deposit, withdraw, buy, sell
          "amount": 100000,
          "currency": "MNT",
          "status": "completed",
          "created_at": "2026-03-31T10:00:00Z"
        }
      ]
    }
    ```

---

## 4. Trading & Market (Арилжаа, Зах зээл)

### 4.1. Нүүр хуудас / Багцын хураангуй (Portfolio Summary)
*   **Endpoint URL:** `GET /api/v1/trading/summary`
*   **Response:**
    ```json
    {
      "status": "success",
      "data": {
        "total_balance_mnt": 2500400,
        "available_balance_mnt": 500400,
        "total_stock_value": 1500000,
        "total_bond_value": 500000,
        "daily_profit_percent": 2.5,
        "daily_profit_amount": 35000
      }
    }
    ```

### 4.2. Хувьцааны жагсаалт (Stocks List)
*   **Endpoint URL:** `GET /api/v1/trading/stocks`
*   **Request Query:** `?category=top_gainers&limit=20`
*   **Response:**
    ```json
    {
      "status": "success",
      "data": [
        {
          "symbol": "APU",
          "company_name": "АПУ ХК",
          "current_price": 1250,
          "change_percent": 1.2,
          "is_watchlist": true
        }
      ]
    }
    ```

### 4.3. Хувьцааны дэлгэрэнгүй (Stock Detail)
*   **Endpoint URL:** `GET /api/v1/trading/stocks/APU`
*   **Response:**
    ```json
    {
      "status": "success",
      "data": {
        "symbol": "APU",
        "company_name": "АПУ ХК",
        "current_price": 1250,
        "high_price": 1260,
        "low_price": 1210,
        "description": "Монголын хамгийн том уух зүйл үйлдвэрлэгч...",
        "order_book": {
          "bids": [[1249, 1500], [1248, 3000]],
          "asks": [[1250, 1000], [1251, 800]]
        }
      }
    }
    ```

### 4.4. Захиалга өгөх (Place Order)
*   **Endpoint URL:** `POST /api/v1/trading/orders`
*   **Request:**
    ```json
    {
      "symbol": "APU",
      "type": "buy", // buy, sell
      "order_type": "limit", // market, limit
      "price": 1249,
      "quantity": 100,
      "pin_code": "1234"
    }
    ```
*   **Response:**
    ```json
    {
      "status": "success",
      "data": {
        "order_id": "ord_102030",
        "status": "pending"
      }
    }
    ```

### 4.5. Захиалгын түүх (Orders List)
*   **Endpoint URL:** `GET /api/v1/trading/orders`
*   **Response:**
    ```json
    {
      "status": "success",
      "data": [
        {
          "order_id": "ord_102030",
          "symbol": "APU",
          "type": "buy",
          "price": 1249,
          "quantity": 100,
          "filled_quantity": 0,
          "status": "active",
          "created_at": "2026-03-31T10:15:00Z"
        }
      ]
    }
    ```

### 4.6. Ханшийн мэдээлэл (Currencies)
*   **Endpoint URL:** `GET /api/v1/market/currencies`
*   **Response:**
    ```json
    {
      "status": "success",
      "data": [
        {
          "pair": "USD/MNT",
          "buy": 3400.5,
          "sell": 3405.0,
          "change": -0.1
        }
      ]
    }
    ```

---

## 5. Other APIs (Бусад)

### 5.1. Мэдэгдэл (Notifications)
*   **Endpoint URL:** `GET /api/v1/notifications`
*   **Response:**
    ```json
    {
      "status": "success",
      "data": [
        {
          "id": "notif_001",
          "title": "Орлого орлоо",
          "body": "Таны дансанд 100,000 төгрөг орлоо.",
          "is_read": false,
          "created_at": "2026-03-31T09:00:00Z"
        }
      ]
    }
    ```

### 5.2. Watchlist нэмэх / хасах
*   **Endpoint URL (Нэмэх):** `POST /api/v1/market/watchlist`
*   **Request:**
    ```json
    {
      "symbol": "APU"
    }
    ```
*   **Endpoint URL (Хасах):** `DELETE /api/v1/market/watchlist/APU`

---
> **Жич:** Энэхүү API документ нь төслийн өнөөгийн дэлгэцүүдийн шаардлагад тулгуурласан бөгөөд бодит backend server-ийн шийдлээс хамаарч field-үүд нэмэгдэж, хасагдах боломжтой.
