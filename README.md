# ShortLink

A simple URL shortening service built with Ruby on Rails.
Allows you to shorten long URLs into compact codes and decode them back to the original URLs. Includes a web frontend, JSON API, persistence across restarts, and considerations for security and scalability.

---

## Table of Contents

1. [Features](#features)
2. [Requirements](#requirements)
3. [Installation & Setup](#installation--setup)
4. [Configuration](#configuration)
5. [Database](#database)
6. [Running the App](#running-the-app)
7. [Usage / API Endpoints](#usage--api-endpoints)
8. [Web Interface](#web-interface)
9. [Testing](#testing)
10. [Security Considerations](#security-considerations)
11. [Scalability Considerations](#scalability-considerations)
12. [Deployment](#deployment)
13. [Additional Documentation](#additional-documentation)

---

## Features

* **Shorten** any HTTP/HTTPS URL into a 6‑character alphanumeric code
* **Decode** a short URL back to its original form
* **Persistent** storage in PostgreSQL so links survive restarts
* **Web UI** for users to shorten/decode URLs in-browser
* **JSON API** under `/api/v1` for programmatic access
* **Dynamic Redirect** of `/<code>` to the original URL
* Validation of URL format, uniqueness enforcement
* Test suite with RSpec request and model specs

---

## Requirements

* Ruby 3.0+
* Rails 6.1+
* PostgreSQL
* Bundler

---

## Installation & Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/Vo-Duc/shortlink.git
   cd shortlink
   ```

2. **Install gems**

   ```bash
   bundle install
   ```

3. **Copy example env file**

   ```bash
   cp .env.example .env
   ```

4. **Edit `.env`** (see [Configuration](#configuration) below)

---

## Configuration

The application reads environment variables from `.env`. At minimum, set:

```dotenv
# Base URL used in API responses
BASE_URL=http://localhost:3000

# PostgreSQL DATABASE_URL, e.g.:
DATABASE_URL=postgres://user:password@localhost:5432/shortlink_development

# (Optional) Rails environment
RAILS_ENV=development
```

Ensure your `.env` file is listed in `.gitignore` so secrets aren’t committed.

---

## Database

1. **Create & migrate**

   ```bash
   bundle exec rails db:create
   bundle exec rails db:migrate
   ```
2. **(Optional) Seed**

   ```bash
   bundle exec rails db:seed
   ```

---

## Running the App

Start the Rails server:

```bash
bundle exec rails server
```

By default, it listens on `http://localhost:3000`.

---

## Usage / API Endpoints

All API endpoints return **JSON**. API controllers skip CSRF verification (`skip_before_action :verify_authenticity_token`), while the web UI uses standard Rails CSRF protection for form submissions.

### 1. Encode (Shorten)

* **Endpoint**: `POST /api/v1/encode`
* **Request Body**:

  ```json
  { "original_url": "https://example.com/long/path?query=1" }
  ```
* **Response** (200 OK):

  ```json
  { "short_url": "http://your.domain/Ab3XyZ" }
  ```
* **Errors**:

  * 400 Bad Request if `original_url` missing or invalid.

### 2. Decode

* **Endpoint**: `POST /api/v1/decode`
* **Request Body**:

  ```json
  { "short_url": "http://your.domain/Ab3XyZ" }
  ```
* **Response** (200 OK):

  ```json
  { "original_url": "https://example.com/long/path?query=1" }
  ```
* **Errors**:

  * 400 Bad Request if `short_url` missing or malformed.
  * 404 Not Found if code does not exist.

### 3. Dynamic Redirect

* **Endpoint**: `GET /:short_code`
* **Behavior**: HTTP 302 redirect to the original URL if found, otherwise returns 404 page.

---

## Web Interface

Visit `http://localhost:3000` for a clean Bootstrap‑based UI:

* **Shorten URL** form
* **Decode URL** form
* Instant inline feedback via JavaScript fetch calls

---

## Testing

RSpec is used for model and request specs.

1. **Setup test database**

   ```bash
   RAILS_ENV=test bundle exec rails db:create db:migrate
   ```
2. **Run tests**

   ```bash
   bundle exec rspec
   ```

Test files live in `spec/models` and `spec/requests`. The `.rspec` file auto-loads `rails_helper` and `spec_helper`.

---

## Security Considerations

This application is a basic URL shortener prototype. We’ve considered several potential security risks:

### 1. Brute-force enumeration of short URLs
- Short codes are only 6 characters and generated randomly, so theoretically guessable.
- In a real-world app, consider rate-limiting and monitoring requests to `/decode` to prevent enumeration.

### 2. CSRF
- CSRF protection is enabled by Rails for all form-based actions.
- The API endpoints do **not** require CSRF tokens by default (as they're stateless), but this should be evaluated if cookie-based sessions are used.

### 3. Malicious or unsafe URLs
- No current validation is in place to block unsafe destinations (e.g., malware sites, internal network links).
- In production, URL scanning (e.g., via Google Safe Browsing API) should be implemented before storing.

### 4. Open Redirect
- This app does not directly redirect to the original URL in the backend, but if a redirect feature is added, it should validate destinations.

### 5. Spam and abuse
- The app currently allows anyone to shorten any URL.
- Mitigation in production: add authentication, rate limits, CAPTCHA.

---

**Note**: As this project is a prototype for demo purposes, these risks are documented but not all are mitigated in code.


---

## Scalability Considerations

* **Code Space**

  * 62⁶ ≈ 56.8 billion possible codes. If you need more, increase length.

* **Collision Probability**

  * At high write volumes, probability of collision rises; consider counter‑based or Snowflake‑style IDs.

* **Database Load**

  * Index `short_url` column for fast lookups (already done in migration).
  * For very large tables, use partitioning or sharding.

* **Caching**

  * Use Redis/Memcached to cache code→URL lookups, reduce DB hits on redirects.

* **Cleanup / TTL**

  * Optionally expire or archive rarely used links via a background job.

* **Distributed Deployment**

  * Stateless web servers + shared DB or separate read replicas.
  * If using in-memory cache for code generation, ensure consistency across nodes.

---

## Deployment

We use [Railway](https://railway.app/) for deployment:

1. **Create a Railway project** and connect your GitHub repository.
2. **Set environment variables** in the Railway dashboard:

   * `BASE_URL`: e.g. `https://your-app.up.railway.app`
   * `DATABASE_URL`: Railway provides a managed Postgres addon with a connection string.
3. **Deploy**: Railway will automatically build and deploy your Rails app.
4. **Run migrations**: In Railway’s console or via CLI:

   ```bash
   railway run bundle exec rails db:migrate
   ```

Deployment complete! Visit your Railway app URL to access the service.

---
## Additional Documentation

More detailed docs, diagrams, and history are available on [DeepWiki](https://deepwiki.com/Vo-Duc/shortlink).
