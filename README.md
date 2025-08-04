# Home Maintenance Technician's App

This app allows technicians to manage and fulfill service orders.

## Features

### Login Screen
- Takes phone number input.
- Cleans and validates number.
- Sends OTP using `MobileAuthServices.receiveOTP()`.

### OTP Screen
- Takes 6-digit OTP.
- Displays countdown timer for resending OTP.
- Verifies OTP via `MobileAuthServices.verifyOTP()`.

### Home Screen
- Initializes Google Map on current technician location using `LocationServices.getCurrentLocation()`.
- Shows swipe action based on order status:
  - `SERVICE_ACCEPTED_BY_TECHNICIAN`: "On The Way" swipe will updates status to `SERVICE_ON_THE_WAY`.
  - `SERVICE_ON_THE_WAY`: "Service Done" swipe will adds order to history, updates status, and clears active request.
- If an active order exists:
  - Displays technician and customer location on map with route using:
    - `polylineSetTowardsCustomer`
    - `deliveryMarker`
- If no active order: displays "No service request in progress".

### History Screen
- Shows past orders using data from Firebase Realtime Database.
- Filters: Today, This Month, This Year.
- Each card shows:
  - Service name
  - Quantity
  - Delivery date and time

### Account Screen
- Displays technician profile.
- On load, calls `loadTechnicianData()` via `ProfileServices.getTechnicianProfileData()`.
- If loading: shows loading indicator.
- If no data:
  - Displays "لا يوجد بيانات"
  - Provides button to navigate to add data.
- If data exists: shows name, mobile number, specialization, and an edit button.

## Models

- `TechnicianModel`: Technician info.
- `ServiceOrderModel`: Full order data.
- `ServiceModel`: Service details.
- `UserAddressModel`: Address info.
- `UserModel`: Basic user info.
- `DirectionModel`: Distance, duration, and route polyline.

## Providers

- `MobileAuthProvider`: Handles mobile number and verification ID.
- `OrderProvider`: Manages service order data.
- `ProfileProvider`: Manages technician profile.
- `TechnicianProvider`: Handles GPS location and route drawing.

## Services

- `MobileAuthServices`: Handles authentication and OTP.
- `GeoFireServices`: Manages technician location in real-time.
- `DirectionServices`: Gets route details via Google Directions API.
- `LocationServices`: Fetches current GPS location.
- `OrderServices`: Handles order details, status, and history.
- `ProfileServices`: Manages technician registration and profile data.
- `PushNotificationServices`: Handles FCM setup and notification delivery.
- `PushNotificationDialogue`: Displays service request dialog.
