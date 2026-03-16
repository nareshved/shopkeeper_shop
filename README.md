# Smart Shop Profit Calculator

### added Supbase with AI Project

A new Flutter project.
![Screenshot_16-3-2026_225124_stitch withgoogle com](https://github.com/user-attachments/assets/ac23a4a6-fa16-4cfe-a43d-6e4e54faede4)



📄 Updated Flutter App PRD
Smart Shop Profit Calculator
1️⃣ Product Overview

Smart Shop Profit Calculator ek simple mobile app hai jo small shop owners ko real profit calculate aur track karne me help karegi.

Bahut saare small business owners ko actual profit pata hi nahi hota, kyuki woh:

cost track nahi karte

extra expenses ignore kar dete hain

quantity calculation galat kar dete hain

Ye app unhe seconds me real profit samjhne me help karegi.

2️⃣ Target Users

Primary Users:

Kirana shop owners

Small business owners

Street vendors

Resellers

New entrepreneurs

Secondary Users:

Students learning business

Flutter learners building real apps

3️⃣ Real World Problems (Unke Problems)

Small shop owners ke paas proper accounting system nahi hota.

Is wajah se ye problems hoti hain:

Problem 1

Shopkeeper ko actual profit nahi pata hota.

Example:

Cost Price = ₹50
Selling Price = ₹60

Shopkeeper sochta hai:

Profit = ₹10

But reality:

Packaging = ₹2
Transport = ₹1
Discount = ₹2

Real Profit = ₹5

Problem 2

Daily sales ke baad total profit track nahi hota.

Example:

Agar din me 10 products bike:

Shopkeeper ko pata nahi hota:

total profit kitna hua

kis product me loss ho raha hai

Problem 3

Most shopkeepers Excel ya accounting apps use nahi kar paate.

Reasons:

apps complex hoti hain

English difficult hoti hai

setup complicated hota hai

Problem 4

Loss detect nahi hota.

Kabhi kabhi shopkeeper loss me product bech raha hota hai without knowing.

4️⃣ App Solution

Ye app shopkeepers ko simple aur visual way me profit samjhne me help karegi.

App ke through shopkeeper:

✔ product ka real profit calculate karega

✔ extra expenses include karega

✔ total profit instantly dekhega

✔ loss warning milegi

✔ daily calculations save ho jayengi

✔ history dekhkar business improve kar sakega

5️⃣ Why Supabase is Added

Supabase ek open-source backend platform hai jo:

Database

Authentication

APIs

Realtime features

provide karta hai.

Is project me Supabase use karne se:

1️⃣ Data cloud me save hoga
2️⃣ User login system banega
3️⃣ History devices me sync hogi
4️⃣ App real production ready banegi

Aur tumhare YouTube viewers Flutter + Backend integration bhi seekhenge.

6️⃣ Tech Stack

Frontend

Flutter

Backend

Supabase

Database

Supabase PostgreSQL

Authentication

Supabase Auth

Local Cache

Hive / SharedPreferences

State Management

Provider / Riverpod

7️⃣ Core Features
1️⃣ Profit Calculator

User inputs:

Product Name

Cost Price

Selling Price

Quantity

Extra Expenses

Formula:

Profit =
(Selling Price − Cost Price) × Quantity − Expenses

Outputs:

Profit per item

Total profit

2️⃣ Profit / Loss Indicator

If profit > 0

Show:

🟢 You made profit

If profit < 0

Show:

🔴 Warning: You are selling at a loss

3️⃣ Save Calculation

User calculation Supabase database me save hogi.

Stored data:

product name

cost price

selling price

quantity

expenses

profit

date

4️⃣ History Screen

User previous calculations dekh sakta hai.

Example:

Product	Profit
Biscuit	₹40
Soap	₹60
Tea	₹25

Data Supabase se fetch hoga.

5️⃣ Share Result

User profit WhatsApp ya message me share kar sakta hai.

Example:

Today's Profit Calculation

Product: Biscuit
Profit: ₹40

8️⃣ App Screens

Total Screens: 5

Screen 1

Splash Screen

Purpose:

App branding.

Elements:

App logo

App name

Loading animation

Screen 2

Login / Signup Screen

Supabase authentication.

Options:

Email signup

Login

Screen 3

Home Screen (Calculator)

Main screen.

Inputs:

Product Name
Cost Price
Selling Price
Quantity
Extra Expenses

Button:

Calculate Profit

Screen 4

Result Screen

Shows detailed breakdown.

Example:

Cost Price: ₹50
Selling Price: ₹60
Quantity: 10
Extra Expense: ₹20

Profit per item = ₹8
Total profit = ₹80

Screen 5

History Screen

Shows all saved calculations from Supabase.

9️⃣ Supabase Database Structure

Table Name:

profit_history

Columns:

id
user_id
product_name
cost_price
selling_price
quantity
expenses
profit
created_at

user_id link hoga Supabase Auth se.
