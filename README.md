# COBOL Expense Tracker v1.2

![COBOL](https://img.shields.io/badge/Language-COBOL-blue?logo=cobol)
![Version](https://img.shields.io/badge/Version-1.2-green)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey)
![Compiler](https://img.shields.io/badge/Compiler-GnuCOBOL%204.x-orange)
![License](https://img.shields.io/badge/License-MIT-yellow)

> A terminal-based expense, deposit, and crypto-stake tracking application built entirely in **COBOL**.

```
==================================================
         COBOL EXPENSE TRACKER v1.2
==================================================
  1. Add Expense
  2. List All Expenses
  3. Category Report
  4. Add Investor Deposit
  5. List Investor Deposits
  6. Add HYPE Stake
  7. List HYPE Stakes
  8. Delete Record
  9. Reset Database
  0. Exit
--------------------------------------------------
Enter choice (0-9):
```

## Why COBOL?

Because the code running the world's banking and government systems deserves to be understood, not feared. This app treats COBOL as what it is: a robust, verbose, surprisingly elegant language for structured data processing.

No frameworks. No dependencies. Just a compiler, a terminal, and flat files that will still be readable in 50 years.

---

## Features

| Menu | Feature | Description |
|------|---------|-------------|
| `1` | **Add Expense** | Date, category, amount, description |
| `2` | **List Expenses** | Formatted table with running total |
| `3` | **Category Report** | Aggregated totals by category |
| `4` | **Add Investor Deposit** | Track investor name, amount, date |
| `5` | **List Deposits** | Formatted table with grand total |
| `6` | **Add HYPE Stake** | Track HYPE amount, APY%, date |
| `7` | **List HYPE Stakes** | Formatted table with total staked |
| `8` | **Delete Record** | Remove individual records by ID |
| `9` | **Reset Database** | Wipe all three files (requires `YES`) |
| `0` | **Exit** | Quit the application |

---

## Installation

Requires **[GnuCOBOL](https://gnucobol.sourceforge.io/)** (`cobc`).

### Linux (Debian / Ubuntu)

```bash
sudo apt update
sudo apt install gnucobol4
```

### macOS

```bash
brew install gnucobol
```

### Windows (MSYS2)

```bash
pacman -S mingw-w64-x86_64-gnucobol
```

Or download a pre-built binary from the [GnuCOBOL releases page](https://sourceforge.net/projects/gnucobol/files/).

Verify installation:

```bash
cobc --version
```

---

## Build & Run

```bash
# Clone or navigate into the project directory
cd cobol-expense-tracker

# Compile
make

# Run
make run

# Clean build artifacts (does NOT delete your data)
make clean
```

Or compile manually:

```bash
cobc -x -Wall -ftext-column=255 -o expense-tracker expense-tracker.cob
./expense-tracker
```

---

## Usage Walkthrough

### Add an Expense

```
Enter choice (0-9): 1
Date (YYYY-MM-DD): 2026-05-01
Category:          Food
Amount:            10.50
Description:       Lunch
--------------------------------------------------
Expense saved successfully. ID: 00001
```

### View Category Report

```
Enter choice (0-9): 3
--------------------------------------------------------------------------------
           CATEGORY SUMMARY REPORT
--------------------------------------------------------------------------------
  CATEGORY                TOTAL
--------------------------------------------------------------------------------
  Food                          $10.50
--------------------------------------------------------------------------------
  GRAND TOTAL:                    $10.50
--------------------------------------------------------------------------------
```

### Delete a Record

```
Enter choice (0-9): 8

  1. Delete Expense
  2. Delete Deposit
  3. Delete HYPE Stake
  4. Back

Enter choice (1-4): 1
Enter Expense ID to delete: 00001
Expense deleted successfully.
```

---

## Data Files

All data is stored as **line-sequential flat files** in the working directory. No database server required.

| File | Record Format |
|------|---------------|
| `expenses.dat` | `[ID:5][YYYY:4][MM:2][DD:2][Category:20][Amount:9(2)][Description:50]` |
| `deposits.dat` | `[ID:5][YYYY:4][MM:2][DD:2][Investor:30][Amount:9(2)][Description:50]` |
| `hype-stakes.dat` | `[ID:5][YYYY:4][MM:2][DD:2][Amount:9(2)][APY:5(2)][Description:50]` |

> **Note:** The application auto-creates these files on first run if they don't exist.

---

## Project Structure

```
cobol-expense-tracker/
├── expense-tracker.cob   # Main COBOL source (fixed format)
├── Makefile              # Build automation
├── README.md             # You are here
├── .gitignore            # Ignores *.dat and compiled binary
├── expenses.dat          # Auto-generated: expense records
├── deposits.dat          # Auto-generated: investor deposits
└── hype-stakes.dat       # Auto-generated: HYPE stake records
```

---

## Architecture Highlights

- **Declarative data architecture** — `DATA DIVISION` explicitly defines every field
- **Sequential file I/O** — `OPEN`, `READ`, `WRITE`, `EXTEND`, `CLOSE`
- **In-memory table processing** — `OCCURS` arrays for category aggregation
- **Formatted reporting** — `PICTURE` clauses for currency and alignment
- **Batch-style menu loop** — classic mainframe interaction pattern
- **Shell integration** — `CALL "SYSTEM"` for `sed` in-place deletion

---

## Roadmap

- [ ] JSON export via C interop
- [ ] REST API bridge (COBOL backend, HTTP frontend)
- [ ] Indexed file access (ISAM-style) for large datasets
- [ ] Auto-backup before destructive operations

---

## Author

**Jason Spooner** ([@Vote4arealclown](https://github.com/Vote4arealclown))

Built to prove that COBOL belongs in a modern portfolio.
