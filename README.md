# Fraud Detection System (URL & QR Code Analysis)

A machine-learning system that checks URLs and QR codes for phishing and fraud. It returns a verdict, a confidence score and a risk level (Safe, Low, Medium, High, Critical), and keeps a per-user scan history with a dashboard.

## Features

- **URL analysis**: scores a link from its structure and patterns using a trained scikit-learn model.
- **QR code analysis**: decodes the URL inside a QR image, then analyzes it.
- **Result details**: fraud-risk gauge, the reasons behind the verdict, and a link-anatomy breakdown.
- **Dashboard**: totals, threat rate, risk breakdown, scan activity and recent scans.
- **History**: filter, search, export to CSV and clear your scans.
- **Accounts**: register and log in (data stored in MySQL).
- **Feedback**: mark a result as correct or wrong to help improve the model.

## Tech stack

| Part | Technology |
|---|---|
| Front end | Streamlit, Altair, pandas |
| Backend API | Flask, Flask-Login, Flask-CORS |
| Machine learning | scikit-learn, NumPy, pandas |
| QR decoding | OpenCV, pyzbar, Pillow |
| Database | MySQL |

## Project structure

```
Fraud_URL_QR_Detection/
├── streamlit_app.py            # Front end (run with Streamlit)
├── script/
│   └── app.py                  # Flask backend API (port 5000)
├── models/
│   ├── fraud_detection_model.py    # Feature extraction, training, prediction
│   └── trained_models/             # Saved model and scaler (.pkl)
├── helpers/db/handler.py       # MySQL access (users, history, stats)
├── database/schema.sql         # Creates the database and tables
├── .streamlit/config.toml      # Theme settings
├── .env                        # Database login and secret key (you edit this)
├── pyproject.toml              # Dependency list
└── start.bat                   # Windows one-click launcher
```

## Requirements

- **Python 3.11 or newer** (https://www.python.org/downloads/). Tick "Add Python to PATH" when installing on Windows.
- **MySQL Server 8.x** (https://dev.mysql.com/downloads/installer/).
- **Windows only:** the *Microsoft Visual C++ Redistributable for Visual Studio 2013 (x64)*. `pyzbar` needs it to read QR codes.
- **Linux only:** the ZBar library: `sudo apt install libzbar0`.
- **Mac only:** `brew install zbar`.

## Setup

### 1. Get the project

Unzip it somewhere without special characters in the path, for example `D:\Fraud_URL_QR_Detection`, and open a terminal in that folder.

### 2. Create a virtual environment and install packages

Windows:

```bash
python -m venv .venv
.venv\Scripts\activate
pip install flask flask-cors flask-login mysql-connector-python numpy opencv-python pandas pillow python-dotenv pyzbar qrcode scikit-learn Werkzeug joblib streamlit requests python-whois altair
```

Mac / Linux:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install flask flask-cors flask-login mysql-connector-python numpy opencv-python pandas pillow python-dotenv pyzbar qrcode scikit-learn Werkzeug joblib streamlit requests python-whois altair
```

If you use [uv](https://docs.astral.sh/uv/), `uv sync` installs the dependencies from `pyproject.toml` instead (also run `uv pip install altair`, which the UI needs).

### 3. Set up MySQL

1. Install MySQL Server and set a **root password** during installation. Make sure the MySQL service is running.
2. Create the database and tables. Open the **MySQL Command Line Client**, enter your password, and run (use your own path, with forward slashes):

   ```sql
   source D:/Fraud_URL_QR_Detection/database/schema.sql;
   ```

   Or from a normal terminal: `mysql -u root -p < database/schema.sql`

3. Check it worked:

   ```sql
   SHOW TABLES FROM fraud_detection_db;
   ```

   You should see `users` and `analysis_history`.

### 4. Configure `.env`

Create `.env` in the project folder and set:

```
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=fraud_detection_db
SECRET_KEY=your_long_random_string
```

Generate a secret key with:

```bash
python -c "import secrets; print(secrets.token_hex(32))"
```

If MySQL is not on the same computer or uses another port, you can also add `DB_HOST=...` and `DB_PORT=...`.

> **Never share or commit `.env`.** It holds your database password and secret key. The included `.gitignore` already excludes it.

## Run the project

You need two programs running at once: the backend and the front end.

### Easiest (Windows)

Double-click **`start.bat`**. It opens both in separate windows, and your browser opens the app.

### Manual

Terminal 1, the backend:

```bash
python script/app.py
```

Wait for `Running on http://127.0.0.1:5000`.

Terminal 2, the front end (same folder, virtual environment active):

```bash
streamlit run streamlit_app.py
```

Open http://localhost:8501 if the browser doesn't open by itself. Press `Ctrl+C` in each terminal to stop.

## Using the app

1. Open the **Create account** tab, register, then log in.
2. **Analyze** tab: paste a URL, or upload a QR image (PNG or JPG), and click Analyze.
3. Read the gauge, the reasons and the link breakdown. Use the feedback box if the verdict looks wrong.
4. **Dashboard** tab: see your totals and charts.
5. **History** tab: filter, export to CSV or clear your scans.

## Backend API (for reference)

The Flask backend runs on `http://127.0.0.1:5000`.

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/register`, `/login`, `/logout` | Accounts |
| GET | `/status` | Current login status |
| POST | `/analyze-url` | Analyze a URL |
| POST | `/analyze-qr` | Analyze a QR image |
| GET | `/history`, `/export-history` | View or export history |
| POST | `/clear-history` | Clear history |
| DELETE | `/delete-history-item/<id>` | Delete one history item |
| GET | `/analysis-stats`, `/analysis-type-stats` | Dashboard data |
| POST | `/submit-feedback` | Send feedback on a result |

## Troubleshooting

| Problem | Fix |
|---|---|
| `FileNotFoundError ... libzbar-64.dll` or `libiconv.dll` | Install the Visual C++ 2013 (x64) Redistributable, then run again. |
| `Access denied for user` | `DB_USER` or `DB_PASSWORD` in `.env` is wrong. Restart the backend after editing. |
| `Can't connect to MySQL server` | Start the MySQL service (on Windows, open *Services* and start `MySQL80`). |
| `Unknown database` | Run `database/schema.sql` again (step 3). |
| Streamlit shows "Could not connect to the backend" | The backend isn't running. Start `script/app.py` first. |
| `InconsistentVersionWarning` from scikit-learn | Harmless. If predictions look wrong, delete the two `.pkl` files in `models/trained_models/` and restart the backend so it retrains. |
| `ModuleNotFoundError` | The virtual environment isn't active, or a package is missing. Activate `.venv` and rerun the `pip install` command. |
| Port 5000 or 8501 already in use | Close the other program using it, or stop the old terminal windows. |

## Notes

- The Flask server runs in debug mode for local use. For real deployment, use a production server such as Gunicorn or Waitress and set a strong `SECRET_KEY`.
- The model gives a probability, not a guarantee. Treat results as guidance and verify suspicious links through official channels.
