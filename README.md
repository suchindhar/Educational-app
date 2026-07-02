<p align="center">
  <img src="https://img.shields.io/badge/⚖️-LawVexia-1E3A5F?style=for-the-badge&labelColor=D4A574&color=1E3A5F" alt="LawVexia"/>
</p>

<p align="center">
  <em>Learn Law Smarter — Constitutional Law I, gamified.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Supabase-3FCF8E?style=flat-square&logo=supabase&logoColor=white" alt="Supabase"/>
  <img src="https://img.shields.io/badge/GitHub%20Pages-222222?style=flat-square&logo=githubpages&logoColor=white" alt="GitHub Pages"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" alt="License"/>
</p>

---

## 🎮 Five Game Modes

<table>
<tr>
<td align="center" width="20%">

### 🃏 Flip & Learn
Animated 3D flashcards with known/unknown tracking

</td>
<td align="center" width="20%">

### ⚡ Quick Quiz
Kahoot-style timed MCQs with streak multipliers

</td>
<td align="center" width="20%">

### ⚖️ Verdict Call
8-second true/false judgment rounds

</td>
<td align="center" width="20%">

### 🔗 Match Pairs
Two-column concept matching with timer

</td>
<td align="center" width="20%">

### 📚 Case Law Memory
Browse cases + auto-generated MCQs

</td>
</tr>
</table>

---

## 📖 Units Covered

| # | Unit | Topics | Case Laws |
|---|------|--------|-----------|
| 1 | **Historical Background** | Regulating Act → Independence Act | Nand Kumar Case |
| 2 | **Making of Constitution** | Drafting, Sources, Preamble, Features | Berubari, Kesavananda Bharati |
| 3 | **Union & Citizenship** | Articles 1–11, Single Citizenship | West Bengal v Union, Babulal Parate |
| 4 | **Fundamental Rights** | Articles 12–35, Doctrines, Writs | Maneka Gandhi, Indra Sawhney, Golaknath |
| 5 | **DPSP & Duties** | Articles 36–51, 51A, 42nd Amendment | Minerva Mills, Champakam Dorairajan |
| 6 | **Amendment & Basic Structure** | Article 368, Basic Structure Doctrine | Kesavananda, Minerva Mills, I.R. Coelho |

---

## ✨ Features

- 🎯 **Smart Content Parser** — Detects illustrations, examples, case laws and renders them as styled callout cards
- 🏆 **XP & Progression** — Earn XP per game, unlock units sequentially
- 👤 **Scholar Profile** — Personalized greeting, avatar, stats
- 📄 **Class Materials** — PDFs & PPTs via Google Docs Viewer
- 🔄 **Remote Content** — Study material fetched from GitHub at runtime
- 🎊 **Confetti & Animations** — Celebrate correct answers, shake on wrong
- 🌐 **Cross-Platform** — Android, iOS, Web, Desktop

---

## 🛠️ Tech Stack

```
Flutter 3.x          → UI Framework
Dart 3.x             → Language
Supabase             → Auth, Database, Storage
Provider             → State Management
GitHub API           → Remote Content CMS
GitHub Actions       → CI/CD → GitHub Pages
flutter_animate      → Entry Animations
confetti             → Celebration Effects
flip_card            → 3D Flashcard Flip
google_fonts         → Plus Jakarta Sans
```

---

## 🚀 Getting Started

```bash
# Clone the repo
git clone https://github.com/suchindhar/Educational-app.git
cd Educational-app

# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Build for production
flutter build web --release --base-href /Educational-app/
```

---

## 📱 Screens

| Welcome | Home | Unit Hub | Quiz | Flashcard |
|---------|------|----------|------|-----------|
| Onboarding with animated logo | 6 color-coded units | Learn + 5 games grid | 20s timer, streak, confetti | 3D flip with known/unknown |

---

## 📂 Project Structure

```
lib/
├── main.dart                    # Entry point + Provider setup
├── constants/
│   └── app_theme.dart           # Scholar Gold palette
├── models/
│   ├── content_models.dart      # GitHub content models
│   └── models.dart              # Supabase/local models
├── services/
│   ├── github_content_service.dart   # Remote content fetcher
│   ├── supabase_service.dart         # Auth, DB, progress
│   └── github_storage_service.dart   # Admin file upload
├── screens/
│   ├── welcome_screen.dart      # Onboarding
│   ├── home_screen.dart         # Main dashboard
│   ├── unit_screen.dart         # Unit hub
│   ├── notes_screen.dart        # Study notes
│   ├── games/                   # 5 game modes
│   └── ...
└── widgets/
    └── ...                      # Reusable components
```

---

## 🤝 Contributing

Contributions welcome! Feel free to open issues or PRs.

---

<p align="center">
  Made for law students
</p>
