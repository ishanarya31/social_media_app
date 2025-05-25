
# 📱 Flutter Social Media App

A fully functional social media application built with **Flutter**, **Firebase**, and **BLoC** for clean and scalable state management. The app includes Firebase authentication, customizable user profiles, a photo posting system, and all the essential features of a modern social media platform.

---

## 🚀 Features

- 🔐 **Firebase Authentication** (Email/Password)
- 👤 **Custom User Profiles** (bio, profile picture, etc.)
- 🖼️ **Photo Upload & Posting System**
- ❤️ **Like Posts**
- 💬 **Comment on Posts**
- 👥 **Follow/Unfollow Other Users**
- 🔄 **Real-time Feed Updates**
- 📦 **BLoC State Management** (clean separation of UI and logic)

---

## 🧱 Tech Stack

| Technology | Description |
|------------|-------------|
| **Flutter**    | UI toolkit for building natively compiled apps |
| **Firebase**   | Backend-as-a-Service (BaaS) |
| **Firestore**  | NoSQL real-time database |
| **Firebase Auth** | User authentication |
| **Firebase Storage** | Store and retrieve user-uploaded images |
| **BLoC**       | State management (event-driven architecture using `flutter_bloc`) |

---

## 📦 Folder Structure

```
lib/
├── features/
│   ├── auth/              # Auth logic and BLoCs
│   ├── profile/           # Profile BLoCs and UI
│   ├── home/              # Post, like, comment features
│   └── themes/            # Follow system logic
├── core/                  # Shared widgets, theme, utils
└── main.dart              # Entry point
```

---

## 🧪 Getting Started

### 1. Clone the repo

```bash
git clone https://github.com/yourusername/social-media-app.git
cd social-media-app
```

### 2. Set up Firebase

- Go to [Firebase Console](https://console.firebase.google.com/)
- Create a new project
- Add Android/iOS apps
- Enable:
  - 🔐 Authentication (Email/Password)
  - 🔥 Firestore Database
  - 🗂️ Firebase Storage

### 3. Add Firebase config to your project

> Do **not** commit API keys. Use `.env` or `secrets.dart` for secrets.

```env
API_KEY=your_firebase_api_key
```

### 4. Install dependencies

```bash
flutter pub get
```

### 5. Run the app

```bash
flutter run
```

---

## 🧠 BLoC Pattern

This project uses the **BLoC** architecture (`flutter_bloc`) for managing application state:

- 🧼 **Clean separation** of UI and business logic
- 🔄 **Reactive data streams** using `Streams` and `Events`
- 📦 Organized per feature (e.g., `auth_bloc`, `post_bloc`, etc.)

> State management is handled inside each feature module using its own BLoC and Cubit classes.

---

## 📸 Screenshots

<!-- Add screenshots here -->
| Login | Feed | Profile |
|-------|------|---------|
| ![](screenshots/login.png) | ![](screenshots/feed.png) | ![](screenshots/profile.png) |

---

## 🔐 Security Best Practices

- ✅ Firestore access is secured with authentication-based rules
- 🔒 No secrets or API keys are exposed in the repo
- 📁 `.env` and `secrets.dart` are in `.gitignore`

---

## 🧑‍💻 Contributing

Pull requests are welcome!

```bash
# Fork and clone
git checkout -b feature/my-feature
git commit -m "Add my feature"
git push origin feature/my-feature
```

---

## 📄 License

This project is licensed under the MIT License.

---

## 🙋‍♂️ Contact

Made with ❤️ by [Ishan Arya](https://github.com/ishanarya31)  
Open an issue for bugs, ideas, or contributions!

