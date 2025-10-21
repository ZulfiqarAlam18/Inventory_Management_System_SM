# Newspaper Inventory Simulation - Monte Carlo Method

## 📋 Table of Contents

- [Overview](#overview)
- [Problem Statement](#problem-statement)
- [System Architecture](#system-architecture)
- [Simulation Parameters](#simulation-parameters)
- [Mathematical Formulas](#mathematical-formulas)
- [Probability Distributions](#probability-distributions)
- [Monte Carlo Simulation Process](#monte-carlo-simulation-process)
- [Optimization Algorithm](#optimization-algorithm)
- [Installation & Usage](#installation--usage)
- [Application Features](#application-features)
- [Example Calculation](#example-calculation)
- [Key Concepts](#key-concepts)
- [Technologies Used](#technologies-used)

---

## 🎯 Overview

This project implements a **Monte Carlo Simulation** for newspaper inventory management using Flutter. The application helps newspaper vendors determine the optimal daily stock level to maximize profit while minimizing losses from unsold inventory and unmet customer demand.

**Project Type:** Inventory Management Optimization  
**Methodology:** Monte Carlo Simulation with Random Digit Assignment  
**Domain:** Operations Research, Supply Chain Management

---

## 📖 Problem Statement

### Business Context

A newspaper vendor faces a daily decision problem:

- Must purchase newspapers before knowing actual demand
- Newspapers are perishable (single-day value only)
- Excess newspapers result in losses
- Insufficient stock leads to lost sales opportunities

### Objective

Determine the **optimal daily stock level** that:

1. Maximizes total profit
2. Minimizes losses from unsold inventory
3. Reduces opportunity costs from unmet demand

---

## 🏗️ System Architecture

### Project Structure

```
bookstore_simulation/
├── lib/
│   ├── main.dart                          # Application entry point
│   ├── models/
│   │   ├── day_result.dart                # Daily simulation results model
│   │   ├── day_simulation_entry.dart      # Random digit simulation entry
│   │   ├── demand_distribution.dart       # Probability distributions
│   │   └── simulation_parameters.dart     # User input parameters
│   ├── screens/
│   │   └── simulation_screen.dart         # Main application screen
│   ├── utils/
│   │   └── simulation_engine.dart         # Core simulation logic
│   └── widgets/
│       ├── day_type_probability_table.dart
│       ├── demand_distribution_table.dart
│       ├── parameter_input_dialog.dart
│       └── random_digit_simulation_table.dart
```

---

## ⚙️ Simulation Parameters

| Parameter           | Symbol | Description                           | Example Value |
| ------------------- | ------ | ------------------------------------- | ------------- |
| **Cost Price**      | C      | Price paid to purchase each newspaper | $15.00        |
| **Selling Price**   | S      | Price at which newspaper is sold      | $25.00        |
| **Scrap Price**     | R      | Recovery value for unsold newspapers  | $5.00         |
| **Lost Profit**     | L      | Opportunity cost per unmet demand     | $10.00        |
| **Stock Level**     | Q      | Number of newspapers purchased daily  | 90            |
| **Simulation Days** | N      | Number of days to simulate            | 20            |
| **Demand**          | D      | Customer demand on a given day        | Variable      |

---

## 🧮 Mathematical Formulas

### A. Basic Calculations

#### 1. Newspapers Sold

```
Newspapers Sold = min(Stock Level, Demand)
Sold = min(Q, D)
```

#### 2. Excess Demand (Unmet)

```
Excess Demand = max(0, Demand - Stock Level)
Unmet = max(0, D - Q)
```

#### 3. Remaining Newspapers (Unsold)

```
Remaining = max(0, Stock Level - Demand)
Unsold = max(0, Q - D)
```

### B. Financial Calculations

#### 4. Total Revenue

```
Revenue = Selling Price × Newspapers Sold
Revenue = S × min(Q, D)
```

#### 5. Lost Profit Cost

```
Lost Profit = Excess Demand × Lost Profit per Unit
Lost Profit = max(0, D - Q) × L
```

#### 6. Scrap Value

```
Scrap Value = Scrap Price × Remaining Newspapers
Scrap Value = R × max(0, Q - D)
```

#### 7. Total Cost

```
Total Cost = Cost Price × Stock Level
Total Cost = C × Q
```

#### 8. Daily Profit (Main Formula)

```
Daily Profit = Revenue - Lost Profit + Scrap Value - Total Cost

Daily Profit = (S × min(Q, D)) - (max(0, D - Q) × L) + (R × max(0, Q - D)) - (C × Q)
```

### C. Per-Unit Metrics

#### 9. Profit per Sale

```
Profit per Sale = Selling Price - Cost Price
Profit per Sale = S - C
```

#### 10. Loss per Unsold

```
Loss per Unsold = Cost Price - Scrap Price
Loss per Unsold = C - R
```

### D. Aggregate Metrics

#### 11. Total Profit (over N days)

```
Total Profit = Σ(Daily Profit) for i = 1 to N
```

#### 12. Average Daily Profit

```
Average Daily Profit = Total Profit / N
```

---

## 📊 Probability Distributions

### A. Day Type Distribution

The simulation uses three day types with fixed probabilities:

| Day Type   | Probability | Cumulative Probability | Random Digit Range |
| ---------- | ----------- | ---------------------- | ------------------ |
| **High**   | 0.40 (40%)  | 0.40                   | 01-40              |
| **Medium** | 0.30 (30%)  | 0.70                   | 41-70              |
| **Low**    | 0.30 (30%)  | 1.00                   | 71-00              |

### B. Demand Distribution by Day Type

Each day type has a unique demand probability distribution:

#### High Demand Distribution

| Demand | Probability | Cumulative | Random Digits |
| ------ | ----------- | ---------- | ------------- |
| 50     | 0.05        | 0.05       | 01-05         |
| 60     | 0.07        | 0.12       | 06-12         |
| 70     | 0.10        | 0.22       | 13-22         |
| 80     | 0.20        | 0.42       | 23-42         |
| 90     | 0.30        | 0.72       | 43-72         |
| 100    | 0.15        | 0.87       | 73-87         |
| 110    | 0.13        | 1.00       | 88-00         |

#### Medium Demand Distribution

| Demand | Probability | Cumulative | Random Digits |
| ------ | ----------- | ---------- | ------------- |
| 50     | 0.12        | 0.12       | 01-12         |
| 60     | 0.16        | 0.28       | 13-28         |
| 70     | 0.30        | 0.58       | 29-58         |
| 80     | 0.20        | 0.78       | 59-78         |
| 90     | 0.08        | 0.86       | 79-86         |
| 100    | 0.06        | 0.92       | 87-92         |
| 110    | 0.08        | 1.00       | 93-00         |

#### Low Demand Distribution

| Demand | Probability | Cumulative | Random Digits |
| ------ | ----------- | ---------- | ------------- |
| 50     | 0.30        | 0.30       | 01-30         |
| 60     | 0.20        | 0.50       | 31-50         |
| 70     | 0.06        | 0.56       | 51-56         |
| 80     | 0.12        | 0.68       | 57-68         |
| 90     | 0.13        | 0.81       | 69-81         |
| 100    | 0.09        | 0.90       | 82-90         |
| 110    | 0.10        | 1.00       | 91-00         |

### Random Digit Assignment Formula

```
Range Start = (Previous Cumulative Probability × 100) + 1
Range End = (Current Cumulative Probability × 100)

Special Case: If Range End = 100, display as "00"
```

**Example:**

- For High day type: P = 0.40
- Cumulative = 0.40
- Range = (0 × 100) + 1 to (0.40 × 100) = 1 to 40 = **01-40**

---

## 🎲 Monte Carlo Simulation Process

### Step-by-Step Algorithm

```
For each day i from 1 to N:

    Step 1: Generate Day Type
    ├── Generate random digit R1 (01-00)
    ├── Map R1 to day type using Day Type Distribution
    └── Result: Day Type ∈ {High, Medium, Low}

    Step 2: Generate Demand
    ├── Use Day Type from Step 1
    ├── Generate random digit R2 (01-00)
    ├── Map R2 to demand using appropriate Demand Distribution
    └── Result: Demand D

    Step 3: Calculate Financial Outcomes
    ├── Sold = min(Q, D)
    ├── Unmet = max(0, D - Q)
    ├── Unsold = max(0, Q - D)
    ├── Revenue = S × Sold
    ├── Lost Profit = L × Unmet
    ├── Scrap = R × Unsold
    ├── Cost = C × Q
    └── Daily Profit = Revenue - Lost Profit + Scrap - Cost

    Step 4: Record Results
    └── Store all metrics for day i

End For

Step 5: Calculate Summary Statistics
├── Total Profit = Σ(Daily Profit)
├── Average Daily Profit = Total Profit / N
├── Total Revenue = Σ(Revenue)
├── Total Lost Profit = Σ(Lost Profit)
└── Total Scrap Value = Σ(Scrap)
```

### Pseudocode

```python
function runSimulation(parameters, numDays):
    results = []

    for day in 1 to numDays:
        # Step 1: Determine day type
        random_digit_day = generateRandomDigit()
        day_type = mapToDayType(random_digit_day)

        # Step 2: Determine demand
        random_digit_demand = generateRandomDigit()
        demand = mapToDemand(random_digit_demand, day_type)

        # Step 3: Calculate metrics
        sold = min(parameters.stockLevel, demand)
        unmet = max(0, demand - parameters.stockLevel)
        unsold = max(0, parameters.stockLevel - demand)

        revenue = parameters.sellingPrice * sold
        lostProfit = parameters.lostProfitPerUnit * unmet
        scrapValue = parameters.scrapPrice * unsold
        totalCost = parameters.costPrice * parameters.stockLevel

        dailyProfit = revenue - lostProfit + scrapValue - totalCost

        # Step 4: Store results
        results.append({
            day: day,
            dayType: day_type,
            demand: demand,
            revenue: revenue,
            lostProfit: lostProfit,
            scrapValue: scrapValue,
            dailyProfit: dailyProfit
        })

    return results
```

---

## 🎯 Optimization Algorithm

### Objective Function

```
Maximize: Total Profit(Q)

Where:
Total Profit(Q) = Σ Daily Profit(Q, Di) for i = 1 to N
```

### Algorithm

```
function findOptimalStockLevel(simulationResults, parameters):

    # Extract demand values
    demands = [result.demand for result in simulationResults]
    minDemand = min(demands)
    maxDemand = max(demands)

    # Initialize
    optimalStock = minDemand
    maxProfit = -∞

    # Test each stock level
    for stockLevel in range(minDemand, maxDemand + 1, step=10):

        totalProfit = 0

        # Calculate profit for this stock level
        for result in simulationResults:
            demand = result.demand

            sold = min(stockLevel, demand)
            unmet = max(0, demand - stockLevel)
            unsold = max(0, stockLevel - demand)

            revenue = parameters.sellingPrice × sold
            lostProfit = parameters.lostProfitPerUnit × unmet
            scrapValue = parameters.scrapPrice × unsold
            cost = parameters.costPrice × stockLevel

            dailyProfit = revenue - lostProfit + scrapValue - cost
            totalProfit += dailyProfit

        # Update optimal if better
        if totalProfit > maxProfit:
            maxProfit = totalProfit
            optimalStock = stockLevel

    return optimalStock, maxProfit
```

### Recommendation Logic

```
currentStock = parameters.stockLevel
optimalStock = findOptimalStockLevel()

if optimalStock > currentStock:
    recommendation = "Increase stock by " + (optimalStock - currentStock)
    reason = "to capture unmet demand"
elif optimalStock < currentStock:
    recommendation = "Decrease stock by " + (currentStock - optimalStock)
    reason = "to reduce waste"
else:
    recommendation = "Current stock level is optimal"
    reason = ""
```

---

## 💻 Installation & Usage

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- An IDE (VS Code, Android Studio, or IntelliJ IDEA)

### Installation Steps

1. **Clone the repository**

```bash
cd "/Users/muzafaribrahim/ALL SEMESTERS/8TH SEMESTER/SM/PBL"
cd bookstore_simulation
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Run the application**

```bash
flutter run
```

### Using the Application

1. **Set Parameters**

   - Click the settings icon or "Set Parameters" button
   - Enter cost price, selling price, scrap price, lost profit, stock level, and simulation days
   - Click "Set Parameters" to confirm

2. **Run Simulation**

   - Click the "Run Simulation" button
   - The application will generate random digit simulations and calculate results

3. **View Results**

   - **Probability Distribution Tables**: Shows day type probabilities and demand distributions
   - **Random Digit Simulation**: Displays random digits and their mapped values
   - **Daily Simulation Results**: Shows financial outcomes for each day
   - **Summary Card**: Displays total metrics and optimal stock recommendation

4. **Analyze Recommendation**
   - Review the optimal stock level suggestion
   - Compare with current stock level
   - Adjust parameters and re-run simulation to test different scenarios

---

## ✨ Application Features

### 1. Parameter Configuration

- **Customizable inputs** for all simulation parameters
- **Input validation** to ensure valid business logic
- **Edit capability** to modify parameters anytime

### 2. Probability Distribution Tables

- **Day Type Probabilities** with visual color coding
- **Demand Distributions** for each day type (High, Medium, Low)
- **Cumulative probabilities** and random digit assignments
- **Side-by-side layout** for easy comparison

### 3. Random Digit Simulation

- Generates random digits for day type determination
- Maps to actual day types using probability ranges
- Generates random digits for demand calculation
- Shows complete simulation process transparently

### 4. Daily Results Analysis

- Displays all financial metrics for each simulated day
- Color-coded day types (🟢 High, 🟠 Medium, 🔴 Low)
- Profit/loss indicators with visual highlighting
- Comprehensive breakdown of revenue, costs, and profit

### 5. Summary Statistics

- **Total Profit** across all simulation days
- **Average Daily Profit** calculation
- **Total Revenue** generated
- **Total Lost Profit** from unmet demand
- **Total Scrap Value** recovered

### 6. Optimization Recommendation

- **Optimal Stock Level** calculation
- **Comparison** with current stock
- **Actionable recommendations** (increase/decrease stock)
- **Reasoning** for the recommendation

### 7. Responsive Design

- **Desktop layout**: Tables displayed side-by-side
- **Mobile layout**: Tables stacked vertically
- **Adaptive spacing**: Optimized for different screen sizes
- **Minimal theme**: Clean black and white design

---

## 📝 Example Calculation

### Given Parameters

```
Cost Price (C) = $15.00
Selling Price (S) = $25.00
Scrap Price (R) = $5.00
Lost Profit per Unmet (L) = $10.00
Stock Level (Q) = 90 newspapers
```

### Scenario 1: Demand = 80 newspapers

**Step 1: Basic Calculations**

```
Newspapers Sold = min(90, 80) = 80
Excess Demand = max(0, 80 - 90) = 0
Remaining Newspapers = max(0, 90 - 80) = 10
```

**Step 2: Financial Calculations**

```
Revenue = $25 × 80 = $2,000.00
Lost Profit = $10 × 0 = $0.00
Scrap Value = $5 × 10 = $50.00
Total Cost = $15 × 90 = $1,350.00
```

**Step 3: Daily Profit**

```
Daily Profit = $2,000 - $0 + $50 - $1,350 = $700.00
```

### Scenario 2: Demand = 100 newspapers

**Step 1: Basic Calculations**

```
Newspapers Sold = min(90, 100) = 90
Excess Demand = max(0, 100 - 90) = 10
Remaining Newspapers = max(0, 90 - 100) = 0
```

**Step 2: Financial Calculations**

```
Revenue = $25 × 90 = $2,250.00
Lost Profit = $10 × 10 = $100.00
Scrap Value = $5 × 0 = $0.00
Total Cost = $15 × 90 = $1,350.00
```

**Step 3: Daily Profit**

```
Daily Profit = $2,250 - $100 + $0 - $1,350 = $800.00
```

### Scenario 3: Demand = 60 newspapers

**Step 1: Basic Calculations**

```
Newspapers Sold = min(90, 60) = 60
Excess Demand = max(0, 60 - 90) = 0
Remaining Newspapers = max(0, 90 - 60) = 30
```

**Step 2: Financial Calculations**

```
Revenue = $25 × 60 = $1,500.00
Lost Profit = $10 × 0 = $0.00
Scrap Value = $5 × 30 = $150.00
Total Cost = $15 × 90 = $1,350.00
```

**Step 3: Daily Profit**

```
Daily Profit = $1,500 - $0 + $150 - $1,350 = $300.00
```

---

## 🧠 Key Concepts

### 1. Monte Carlo Simulation

- **Definition**: A computational technique that uses random sampling to obtain numerical results
- **Purpose**: Model systems with inherent uncertainty and variability
- **Advantage**: Can simulate complex scenarios that are difficult to solve analytically

### 2. Random Digit Method

- **Technique**: Maps random numbers (01-00) to probability ranges
- **Ensures**: Statistical validity and reproducible results
- **Implementation**: Based on cumulative probability distributions

### 3. Newsvendor Problem

- **Classic Operations Research Problem**: Inventory decision under uncertain demand
- **Trade-off**: Balance between overstocking (waste) and understocking (lost sales)
- **Solution**: Find optimal order quantity to maximize expected profit

### 4. Probability Distribution

- **Discrete Distribution**: Finite set of possible outcomes with assigned probabilities
- **Cumulative Distribution Function (CDF)**: Sum of probabilities up to a given point
- **Application**: Models day types and demand patterns

### 5. Inventory Management Concepts

- **Perishable Inventory**: Items with limited shelf life (newspapers are single-day value)
- **Opportunity Cost**: Lost profit from inability to meet demand
- **Salvage Value**: Recovery value from unsold items (scrap price)

### 6. Expected Value

```
E[Profit] = Σ (Probability × Outcome) for all possible outcomes
```

### 7. Sensitivity Analysis

- Running multiple simulations with different parameters
- Understanding how changes affect outcomes
- Identifying robust strategies

---

## 🛠️ Technologies Used

### Frontend Framework

- **Flutter** (3.24.5): Cross-platform UI framework
- **Dart** (3.5.4): Programming language

### State Management

- **StatefulWidget**: Built-in Flutter state management
- **setState()**: UI updates based on simulation results

### Data Models

- Custom Dart classes for:
  - Simulation parameters
  - Day results
  - Demand distributions
  - Random digit entries

### UI Components

- **Material Design**: Clean, minimal black & white theme
- **DataTables**: Display simulation results and probability distributions
- **Cards**: Organize information visually
- **Responsive Layout**: LayoutBuilder for adaptive design

### Algorithms

- Random number generation (Dart's `Random` class)
- Monte Carlo simulation engine
- Optimization algorithm for stock level recommendation

---

## 📈 Future Enhancements

### Potential Improvements

1. **Advanced Analytics**

   - Profit distribution charts
   - Demand pattern visualization
   - Historical trend analysis

2. **Multiple Stock Levels**

   - Compare different stock levels simultaneously
   - Side-by-side comparison charts

3. **Export Functionality**

   - Export results to CSV/Excel
   - PDF report generation
   - Share simulation configurations

4. **Advanced Probability Distributions**

   - Normal distribution support
   - Poisson distribution for demand
   - User-defined custom distributions

5. **Scenario Analysis**

   - Best case / Worst case / Expected case
   - Confidence intervals
   - Risk metrics (VaR, CVaR)

6. **Database Integration**

   - Save simulation history
   - Compare past simulations
   - Track parameter changes over time

7. **Multi-Product Support**
   - Simulate inventory for multiple products
   - Cross-product optimization
   - Portfolio analysis

---

## 📚 References

### Academic Papers

1. Monte Carlo Simulation in Inventory Management
2. The Newsvendor Problem: Review and Extensions
3. Stochastic Inventory Models

### Books

1. "Operations Research: An Introduction" by Hamdy A. Taha
2. "Simulation Modeling and Analysis" by Averill M. Law
3. "Introduction to Operations Research" by Frederick S. Hillier

### Online Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Monte Carlo Methods - Wikipedia](https://en.wikipedia.org/wiki/Monte_Carlo_method)

---

## 👥 Contributors

**Developer:** Muzafar Ibrahim  & Zulfiqar Alam
**Course:** Simulation Modeling by Dr. Sania  Bhatti
**Institution:** MUET, Jamshoro. 
**Date:** October 21, 2025

---

## 📄 License

This project is created for educational purposes as part of a semester project.

---

## 📞 Contact

For questions or feedback about this simulation:

- **Email:** 21sw055@students.muet.edu.pk
- **GitHub:** Muzafar Ibrahim

---

## 🙏 Acknowledgments

Special thanks to:

- Course instructor for problem formulation and guidance
- Flutter community for excellent documentation
- Open-source contributors

---

**Last Updated:** October 21, 2025  
**Version:** 1.0.0  
**Status:** ✅ Complete and Functional
