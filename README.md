# Campus Vote App

[![Flutter](https://img.shields.io/badge/Flutter-3.16+-blue)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

**A secure digital platform for student elections** – nominate candidates, campaign online, and cast votes from your phone or computer.

## Table of Contents
1. [Features](#features)
2. [Tech Stack](#tech-stack)
3. [Setup Instructions](#setup-instructions)
4. [How to Contribute](#how-to-contribute)
5. [License](#license)

## Features
- Student login with college email
- Candidate nomination and profile pages
- Anonymous, one‑person‑one‑vote system
- Real‑time election results
- Admin dashboard to manage voting periods

## Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Rust + Actix-web
- **Database:** PostgreSQL + SQLite (local cache)
- **Authentication:** Firebase Auth

## Setup Instructions

### Prerequisites
- Flutter SDK 3.16+
- Android Studio or Xcode (for mobile)
- Git

### Steps
```bash
# 1. Clone the repository
git clone https://github.com/chester-dev-alt/campus_vote_app.git
cd campus_vote_app

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run -d chrome
