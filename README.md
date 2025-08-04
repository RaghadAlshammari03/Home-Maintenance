# Service Home Maintenance User's App

a mobile application that allows users to request home maintenance services, track service status, and manage their orders with ease.

## Features

### Login Screen
- Country picker and phone number input.
- Validates and formats number.
- Sends OTP via `MobileAuthServices.receiveOTP()`.

### OTP Screen
- Displays entered number and OTP input field.
- 60-second timer for resending OTP.
- Verifies OTP using `MobileAuthServices.verifyOTP()`.

### Home Screen
- Displays current address at the top via `ProfileProvider`.
- Clickable address opens `ViewAddressOverlayScreen`.
- Carousel slider with images and page indicators.
- Three service categories:
  - Air Conditioning
  - Electricity
  - Plumbing
- Three informational cards.
- Customer reviews carousel.

### Services Screens
- Category screens:
  - `AirConditionPage`
  - `ElectricityPage`
  - `PlumbingPage`
- Each screen lists services from respective lists.
- Each service includes:
  - Name, details, quantity selector
  - "Add to Cart" button
 
### Basket Screen
- Lists cart items using `ItemOrderProvider`.
- If cart is empty: displays "السلة فارغة".
- Each item:
  - Shows name, details, quantity.
  - Quantity can be adjusted.
- "اطلب الآن" button appears when items exist.
  - Generates order IDs.
  - Submits orders using `ServiceOrderServices.serviceOrderRequest`.
  - Clears the cart after submission.

### History Orders Screen
- Displays previous orders with Arabic title.
- Cycles between Today, This Month, and This Year using one filter button.
- Fetches data from Firebase Realtime DB using `userUID`.
- Each card shows:
  - Service name
  - Service charges
  - Quantity
  - Date and time (formatted)

### Account Screen
- Displays phone number.
- Options:
  - Previous Orders
  - Address History
  - Payment Methods
  - Contact Us
  - Logout

### Addresses Screen
- Shows saved addresses and active status.
- Add, delete, or activate addresses.
- Uses Provider to fetch and update data.

### Add Address Screen
- Select location using map or GPS.
- Enter house number, street/apartment, and label.
- Saves data to backend with validation.

## Models

- `ServiceOrderModel`: Represents a full service order.
- `ServiceModel`: Service name, type, quantity, and metadata.
- `TechnicianModel`: Technician data.
- `UserAddressModel`: User address info.
- `UserModel`: Basic user information.

## Providers

- `MobileAuthProvider`: Manages phone number and OTP.
- `ItemOrderProvider`: Manages cart items.
- `ProfileProvider`: Manages user profile and addresses.

## Services

- `mobileAuthServices.dart`: Handles login, OTP, and registration flow.
- `locationServices.dart`: Gets current location using Geolocator.
- `pushNotificationServices.dart`: Manages FCM setup and delivery.
- `serviceOrderServices.dart`: Handles cart, order creation, and updates.
- `userDataCRUDServices.dart`: Manages user profile and address data.
