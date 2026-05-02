       IDENTIFICATION DIVISION.
       PROGRAM-ID. EXPENSE-TRACKER.
       AUTHOR. Jason Spooner.
       DATE-WRITTEN. 2026-05-02.
       
      *---------------------------------------------------------------*
      * COBOL EXPENSE TRACKER v1.2                                    *
      *                                                               *
      * Features:                                                     *
      *   - Expense tracking with category reports                    *
      *   - Investor deposit tracking                                 *
      *   - Staked HYPE coin tracking                                 *
      *   - Delete individual records                                 *
      *---------------------------------------------------------------*
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT EXPENSE-FILE ASSIGN TO "expenses.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.
           SELECT DEPOSIT-FILE ASSIGN TO "deposits.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-DEP-STATUS.
           SELECT HYPE-FILE ASSIGN TO "hype-stakes.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-HYPE-STATUS.
       
       DATA DIVISION.
       FILE SECTION.
       FD EXPENSE-FILE.
       01 EXPENSE-RECORD.
          05 EXP-ID           PIC 9(5).
          05 EXP-DATE.
             10 EXP-YEAR      PIC 9(4).
             10 EXP-MONTH     PIC 9(2).
             10 EXP-DAY       PIC 9(2).
          05 EXP-CATEGORY     PIC X(20).
          05 EXP-AMOUNT       PIC 9(7)V99.
          05 EXP-DESC         PIC X(50).
       
       FD DEPOSIT-FILE.
       01 DEPOSIT-RECORD.
          05 DEP-ID           PIC 9(5).
          05 DEP-DATE.
             10 DEP-YEAR      PIC 9(4).
             10 DEP-MONTH     PIC 9(2).
             10 DEP-DAY       PIC 9(2).
          05 DEP-INVESTOR     PIC X(30).
          05 DEP-AMOUNT       PIC 9(9)V99.
          05 DEP-DESC         PIC X(50).
       
       FD HYPE-FILE.
       01 HYPE-RECORD.
          05 HYPE-ID          PIC 9(5).
          05 HYPE-DATE.
             10 HYPE-YEAR     PIC 9(4).
             10 HYPE-MONTH    PIC 9(2).
             10 HYPE-DAY      PIC 9(2).
          05 HYPE-AMOUNT      PIC 9(9)V99.
          05 HYPE-APY         PIC 9(3)V99.
          05 HYPE-DESC        PIC X(50).
       
       WORKING-STORAGE SECTION.
       01 WS-EOF             PIC A(1)     VALUE 'N'.
       01 WS-CHOICE          PIC 9(2)     VALUE 99.
       01 WS-PAUSE           PIC X(1)     VALUE SPACES.
       
      * ID counters
       01 WS-NEXT-ID         PIC 9(5)     VALUE 0.
       01 WS-NEXT-DEP-ID     PIC 9(5)     VALUE 0.
       01 WS-NEXT-HYPE-ID    PIC 9(5)     VALUE 0.
       
       01 WS-TOTAL-AMOUNT    PIC 9(9)V99  VALUE 0.
       01 WS-CAT-TOTAL       PIC 9(9)V99  VALUE 0.
       01 WS-RECORD-COUNT    PIC 9(5)     VALUE 0.
       01 WS-CAT-COUNT       PIC 9(2)     VALUE 0.
       01 I                  PIC 9(2)     VALUE 0.
       01 J                  PIC 9(2)     VALUE 0.
       01 WS-FOUND           PIC A(1)     VALUE 'N'.
       01 WS-FILE-STATUS     PIC XX       VALUE "00".
       01 WS-DEP-STATUS      PIC XX       VALUE "00".
       01 WS-HYPE-STATUS     PIC XX       VALUE "00".
       
      * Delete support
       01 WS-DELETE-ID       PIC 9(5)     VALUE 0.
       01 WS-SYSTEM-CMD      PIC X(80)    VALUE SPACES.
       
      * Input fields
       01 WS-INPUT-DATE.
          05 WS-IN-YEAR      PIC 9(4).
          05 FILLER          PIC X(1)     VALUE '-'.
          05 WS-IN-MONTH     PIC 9(2).
          05 FILLER          PIC X(1)     VALUE '-'.
          05 WS-IN-DAY       PIC 9(2).
       01 WS-INPUT-CATEGORY  PIC X(20).
       01 WS-INPUT-AMOUNT    PIC 9(9)V99.
       01 WS-INPUT-DESC      PIC X(50).
       01 WS-INPUT-INVESTOR  PIC X(30).
       01 WS-INPUT-APY       PIC 9(3)V99.
       
      * Formatted output fields
       01 WS-FMT-ID          PIC Z(4)9.
       01 WS-FMT-DATE        PIC X(10).
       01 WS-FMT-AMOUNT      PIC $$$,$$$,$$9.99.
       01 WS-FMT-TOTAL       PIC $$$,$$$,$$9.99.
       01 WS-FMT-CAT-TOTAL   PIC $$$,$$$,$$9.99.
       01 WS-FMT-APY         PIC ZZ9.99.
       
      * Table for category summary (up to 20 unique categories)
       01 WS-CATEGORY-TABLE.
          05 WS-CAT-ENTRY OCCURS 20 TIMES.
             10 WS-CAT-NAME   PIC X(20)   VALUE SPACES.
             10 WS-CAT-TOT    PIC 9(9)V99 VALUE 0.
       
      * Screen formatting
       01 WS-HEADER-LINE     PIC X(80) VALUE ALL '-'.
       01 WS-BLANK-LINE      PIC X(80) VALUE SPACES.
       
       PROCEDURE DIVISION.
       MAIN-PARA.
           PERFORM INIT-CHECK
           PERFORM DISPLAY-MENU UNTIL WS-CHOICE = 0
           STOP RUN.
       
      *---------------------------------------------------------------*
      * Initialize - check files, get next IDs                        *
      *---------------------------------------------------------------*
       INIT-CHECK.
           OPEN INPUT EXPENSE-FILE
           IF WS-FILE-STATUS = "35"
               OPEN OUTPUT EXPENSE-FILE
               CLOSE EXPENSE-FILE
               MOVE 1 TO WS-NEXT-ID
           ELSE
               MOVE 'N' TO WS-EOF
               PERFORM READ-ALL-IDS
               CLOSE EXPENSE-FILE
           END-IF
           
           OPEN INPUT DEPOSIT-FILE
           IF WS-DEP-STATUS = "35"
               OPEN OUTPUT DEPOSIT-FILE
               CLOSE DEPOSIT-FILE
               MOVE 1 TO WS-NEXT-DEP-ID
           ELSE
               MOVE 'N' TO WS-EOF
               PERFORM READ-ALL-DEP-IDS
               CLOSE DEPOSIT-FILE
           END-IF
           
           OPEN INPUT HYPE-FILE
           IF WS-HYPE-STATUS = "35"
               OPEN OUTPUT HYPE-FILE
               CLOSE HYPE-FILE
               MOVE 1 TO WS-NEXT-HYPE-ID
           ELSE
               MOVE 'N' TO WS-EOF
               PERFORM READ-ALL-HYPE-IDS
               CLOSE HYPE-FILE
           END-IF.
       
       READ-ALL-IDS.
           PERFORM UNTIL WS-EOF = 'Y'
               READ EXPENSE-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF
                   NOT AT END
                       MOVE EXP-ID TO WS-NEXT-ID
               END-READ
           END-PERFORM
           ADD 1 TO WS-NEXT-ID.
       
       READ-ALL-DEP-IDS.
           PERFORM UNTIL WS-EOF = 'Y'
               READ DEPOSIT-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF
                   NOT AT END
                       MOVE DEP-ID TO WS-NEXT-DEP-ID
               END-READ
           END-PERFORM
           ADD 1 TO WS-NEXT-DEP-ID.
       
       READ-ALL-HYPE-IDS.
           PERFORM UNTIL WS-EOF = 'Y'
               READ HYPE-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF
                   NOT AT END
                       MOVE HYPE-ID TO WS-NEXT-HYPE-ID
               END-READ
           END-PERFORM
           ADD 1 TO WS-NEXT-HYPE-ID.
       
      *---------------------------------------------------------------*
      * Main Menu                                                     *
      *---------------------------------------------------------------*
       DISPLAY-MENU.
           DISPLAY WS-BLANK-LINE
           DISPLAY "=================================================="
           DISPLAY "         COBOL EXPENSE TRACKER v1.2               "
           DISPLAY "=================================================="
           DISPLAY "  1. Add Expense"
           DISPLAY "  2. List All Expenses"
           DISPLAY "  3. Category Report"
           DISPLAY "  4. Add Investor Deposit"
           DISPLAY "  5. List Investor Deposits"
           DISPLAY "  6. Add HYPE Stake"
           DISPLAY "  7. List HYPE Stakes"
           DISPLAY "  8. Delete Record"
           DISPLAY "  9. Reset Database"
           DISPLAY "  0. Exit"
           DISPLAY "--------------------------------------------------"
           DISPLAY "Enter choice (0-9): " WITH NO ADVANCING
           ACCEPT WS-CHOICE
           
           EVALUATE WS-CHOICE
               WHEN 1
                   PERFORM ADD-EXPENSE
               WHEN 2
                   PERFORM LIST-EXPENSES
               WHEN 3
                   PERFORM CATEGORY-REPORT
               WHEN 4
                   PERFORM ADD-DEPOSIT
               WHEN 5
                   PERFORM LIST-DEPOSITS
               WHEN 6
                   PERFORM ADD-HYPE-STAKE
               WHEN 7
                   PERFORM LIST-HYPE-STAKES
               WHEN 8
                   PERFORM DELETE-MENU
               WHEN 9
                   PERFORM RESET-DATABASE
               WHEN 0
                   DISPLAY "Goodbye."
               WHEN OTHER
                   DISPLAY "Invalid choice. Press Enter to continue..."
                   ACCEPT WS-PAUSE
           END-EVALUATE.
       
      *---------------------------------------------------------------*
      * Add Expense                                                   *
      *---------------------------------------------------------------*
       ADD-EXPENSE.
           DISPLAY WS-BLANK-LINE
           DISPLAY "=================================================="
           DISPLAY "              ADD NEW EXPENSE                     "
           DISPLAY "=================================================="
           
           DISPLAY "Date (YYYY-MM-DD): " WITH NO ADVANCING
           ACCEPT WS-INPUT-DATE
           
           DISPLAY "Category:          " WITH NO ADVANCING
           ACCEPT WS-INPUT-CATEGORY
           
           DISPLAY "Amount:             " WITH NO ADVANCING
           ACCEPT WS-INPUT-AMOUNT
           
           DISPLAY "Description:        " WITH NO ADVANCING
           ACCEPT WS-INPUT-DESC
           
           MOVE WS-NEXT-ID TO EXP-ID
           MOVE WS-IN-YEAR TO EXP-YEAR
           MOVE WS-IN-MONTH TO EXP-MONTH
           MOVE WS-IN-DAY TO EXP-DAY
           MOVE WS-INPUT-CATEGORY TO EXP-CATEGORY
           MOVE WS-INPUT-AMOUNT TO EXP-AMOUNT
           MOVE WS-INPUT-DESC TO EXP-DESC
           
           OPEN EXTEND EXPENSE-FILE
           WRITE EXPENSE-RECORD
           CLOSE EXPENSE-FILE
           
           ADD 1 TO WS-NEXT-ID
           
           DISPLAY "--------------------------------------------------"
           DISPLAY "Expense saved successfully. ID: " EXP-ID
           DISPLAY "Press Enter to continue..."
           ACCEPT WS-PAUSE.
       
      *---------------------------------------------------------------*
      * List All Expenses                                             *
      *---------------------------------------------------------------*
       LIST-EXPENSES.
           MOVE 'N' TO WS-EOF
           MOVE 0 TO WS-RECORD-COUNT
           MOVE 0 TO WS-TOTAL-AMOUNT
           
           DISPLAY WS-BLANK-LINE
           DISPLAY WS-HEADER-LINE
           DISPLAY "  ID    DATE        CATEGORY             AMOUNT     DESCRIPTION"
           DISPLAY WS-HEADER-LINE
           
           OPEN INPUT EXPENSE-FILE
           PERFORM UNTIL WS-EOF = 'Y'
               READ EXPENSE-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF
                   NOT AT END
                       ADD 1 TO WS-RECORD-COUNT
                       ADD EXP-AMOUNT TO WS-TOTAL-AMOUNT
                       PERFORM FORMAT-AND-DISPLAY
               END-READ
           END-PERFORM
           CLOSE EXPENSE-FILE
           
           DISPLAY WS-HEADER-LINE
           MOVE WS-TOTAL-AMOUNT TO WS-FMT-TOTAL
           DISPLAY "  Total Records: " WS-RECORD-COUNT
           DISPLAY "  Grand Total:   " WS-FMT-TOTAL
           DISPLAY WS-HEADER-LINE
           DISPLAY "Press Enter to continue..."
           ACCEPT WS-PAUSE.
       
       FORMAT-AND-DISPLAY.
           MOVE EXP-ID TO WS-FMT-ID
           STRING EXP-YEAR "-" EXP-MONTH "-" EXP-DAY DELIMITED BY SIZE
               INTO WS-FMT-DATE
           MOVE EXP-AMOUNT TO WS-FMT-AMOUNT
           DISPLAY "  " WS-FMT-ID "  " WS-FMT-DATE "  " 
                   EXP-CATEGORY "  " WS-FMT-AMOUNT "  " EXP-DESC.
       
      *---------------------------------------------------------------*
      * Category Report                                               *
      *---------------------------------------------------------------*
       CATEGORY-REPORT.
           MOVE 'N' TO WS-EOF
           MOVE 0 TO WS-CAT-COUNT
           
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > 20
               MOVE SPACES TO WS-CAT-NAME(I)
               MOVE 0 TO WS-CAT-TOT(I)
           END-PERFORM
           
           OPEN INPUT EXPENSE-FILE
           PERFORM UNTIL WS-EOF = 'Y'
               READ EXPENSE-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF
                   NOT AT END
                       PERFORM ADD-TO-CATEGORY
               END-READ
           END-PERFORM
           CLOSE EXPENSE-FILE
           
           DISPLAY WS-BLANK-LINE
           DISPLAY WS-HEADER-LINE
           DISPLAY "           CATEGORY SUMMARY REPORT                "
           DISPLAY WS-HEADER-LINE
           DISPLAY "  CATEGORY                TOTAL"
           DISPLAY WS-HEADER-LINE
           
           MOVE 0 TO WS-TOTAL-AMOUNT
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > 20
               IF WS-CAT-NAME(I) NOT = SPACES
                   MOVE WS-CAT-TOT(I) TO WS-FMT-CAT-TOTAL
                   DISPLAY "  " WS-CAT-NAME(I) "  " WS-FMT-CAT-TOTAL
                   ADD WS-CAT-TOT(I) TO WS-TOTAL-AMOUNT
               END-IF
           END-PERFORM
           
           DISPLAY WS-HEADER-LINE
           MOVE WS-TOTAL-AMOUNT TO WS-FMT-TOTAL
           DISPLAY "  GRAND TOTAL:            " WS-FMT-TOTAL
           DISPLAY WS-HEADER-LINE
           DISPLAY "Press Enter to continue..."
           ACCEPT WS-PAUSE.
       
       ADD-TO-CATEGORY.
           MOVE 'N' TO WS-FOUND
           PERFORM VARYING J FROM 1 BY 1 UNTIL J > WS-CAT-COUNT OR WS-FOUND = 'Y'
               IF WS-CAT-NAME(J) = EXP-CATEGORY
                   ADD EXP-AMOUNT TO WS-CAT-TOT(J)
                   MOVE 'Y' TO WS-FOUND
               END-IF
           END-PERFORM
           
           IF WS-FOUND = 'N'
               IF WS-CAT-COUNT < 20
                   ADD 1 TO WS-CAT-COUNT
                   MOVE EXP-CATEGORY TO WS-CAT-NAME(WS-CAT-COUNT)
                   MOVE EXP-AMOUNT TO WS-CAT-TOT(WS-CAT-COUNT)
               ELSE
                   DISPLAY "Warning: Category table full. Ignoring: " EXP-CATEGORY
               END-IF
           END-IF.
       
      *---------------------------------------------------------------*
      * Add Investor Deposit                                          *
      *---------------------------------------------------------------*
       ADD-DEPOSIT.
           DISPLAY WS-BLANK-LINE
           DISPLAY "=================================================="
           DISPLAY "           ADD INVESTOR DEPOSIT                   "
           DISPLAY "=================================================="
           
           DISPLAY "Date (YYYY-MM-DD): " WITH NO ADVANCING
           ACCEPT WS-INPUT-DATE
           
           DISPLAY "Investor Name:     " WITH NO ADVANCING
           ACCEPT WS-INPUT-INVESTOR
           
           DISPLAY "Amount:             " WITH NO ADVANCING
           ACCEPT WS-INPUT-AMOUNT
           
           DISPLAY "Description:        " WITH NO ADVANCING
           ACCEPT WS-INPUT-DESC
           
           MOVE WS-NEXT-DEP-ID TO DEP-ID
           MOVE WS-IN-YEAR TO DEP-YEAR
           MOVE WS-IN-MONTH TO DEP-MONTH
           MOVE WS-IN-DAY TO DEP-DAY
           MOVE WS-INPUT-INVESTOR TO DEP-INVESTOR
           MOVE WS-INPUT-AMOUNT TO DEP-AMOUNT
           MOVE WS-INPUT-DESC TO DEP-DESC
           
           OPEN EXTEND DEPOSIT-FILE
           WRITE DEPOSIT-RECORD
           CLOSE DEPOSIT-FILE
           
           ADD 1 TO WS-NEXT-DEP-ID
           
           DISPLAY "--------------------------------------------------"
           DISPLAY "Deposit saved successfully. ID: " DEP-ID
           DISPLAY "Press Enter to continue..."
           ACCEPT WS-PAUSE.
       
      *---------------------------------------------------------------*
      * List Investor Deposits                                        *
      *---------------------------------------------------------------*
       LIST-DEPOSITS.
           MOVE 'N' TO WS-EOF
           MOVE 0 TO WS-RECORD-COUNT
           MOVE 0 TO WS-TOTAL-AMOUNT
           
           DISPLAY WS-BLANK-LINE
           DISPLAY WS-HEADER-LINE
           DISPLAY "  ID    DATE        INVESTOR                   AMOUNT     DESCRIPTION"
           DISPLAY WS-HEADER-LINE
           
           OPEN INPUT DEPOSIT-FILE
           PERFORM UNTIL WS-EOF = 'Y'
               READ DEPOSIT-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF
                   NOT AT END
                       ADD 1 TO WS-RECORD-COUNT
                       ADD DEP-AMOUNT TO WS-TOTAL-AMOUNT
                       PERFORM FORMAT-DEPOSIT
               END-READ
           END-PERFORM
           CLOSE DEPOSIT-FILE
           
           DISPLAY WS-HEADER-LINE
           MOVE WS-TOTAL-AMOUNT TO WS-FMT-TOTAL
           DISPLAY "  Total Records: " WS-RECORD-COUNT
           DISPLAY "  Grand Total:   " WS-FMT-TOTAL
           DISPLAY WS-HEADER-LINE
           DISPLAY "Press Enter to continue..."
           ACCEPT WS-PAUSE.
       
       FORMAT-DEPOSIT.
           MOVE DEP-ID TO WS-FMT-ID
           STRING DEP-YEAR "-" DEP-MONTH "-" DEP-DAY DELIMITED BY SIZE
               INTO WS-FMT-DATE
           MOVE DEP-AMOUNT TO WS-FMT-AMOUNT
           DISPLAY "  " WS-FMT-ID "  " WS-FMT-DATE "  " 
                   DEP-INVESTOR "  " WS-FMT-AMOUNT "  " DEP-DESC.
       
      *---------------------------------------------------------------*
      * Add HYPE Stake                                                *
      *---------------------------------------------------------------*
       ADD-HYPE-STAKE.
           DISPLAY WS-BLANK-LINE
           DISPLAY "=================================================="
           DISPLAY "              ADD HYPE STAKE                      "
           DISPLAY "=================================================="
           
           DISPLAY "Date (YYYY-MM-DD): " WITH NO ADVANCING
           ACCEPT WS-INPUT-DATE
           
           DISPLAY "HYPE Amount:        " WITH NO ADVANCING
           ACCEPT WS-INPUT-AMOUNT
           
           DISPLAY "APY (%):            " WITH NO ADVANCING
           ACCEPT WS-INPUT-APY
           
           DISPLAY "Description:        " WITH NO ADVANCING
           ACCEPT WS-INPUT-DESC
           
           MOVE WS-NEXT-HYPE-ID TO HYPE-ID
           MOVE WS-IN-YEAR TO HYPE-YEAR
           MOVE WS-IN-MONTH TO HYPE-MONTH
           MOVE WS-IN-DAY TO HYPE-DAY
           MOVE WS-INPUT-AMOUNT TO HYPE-AMOUNT
           MOVE WS-INPUT-APY TO HYPE-APY
           MOVE WS-INPUT-DESC TO HYPE-DESC
           
           OPEN EXTEND HYPE-FILE
           WRITE HYPE-RECORD
           CLOSE HYPE-FILE
           
           ADD 1 TO WS-NEXT-HYPE-ID
           
           DISPLAY "--------------------------------------------------"
           DISPLAY "HYPE stake saved successfully. ID: " HYPE-ID
           DISPLAY "Press Enter to continue..."
           ACCEPT WS-PAUSE.
       
      *---------------------------------------------------------------*
      * List HYPE Stakes                                              *
      *---------------------------------------------------------------*
       LIST-HYPE-STAKES.
           MOVE 'N' TO WS-EOF
           MOVE 0 TO WS-RECORD-COUNT
           MOVE 0 TO WS-TOTAL-AMOUNT
           
           DISPLAY WS-BLANK-LINE
           DISPLAY WS-HEADER-LINE
           DISPLAY "  ID    DATE        AMOUNT           APY     DESCRIPTION"
           DISPLAY WS-HEADER-LINE
           
           OPEN INPUT HYPE-FILE
           PERFORM UNTIL WS-EOF = 'Y'
               READ HYPE-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF
                   NOT AT END
                       ADD 1 TO WS-RECORD-COUNT
                       ADD HYPE-AMOUNT TO WS-TOTAL-AMOUNT
                       PERFORM FORMAT-HYPE
               END-READ
           END-PERFORM
           CLOSE HYPE-FILE
           
           DISPLAY WS-HEADER-LINE
           MOVE WS-TOTAL-AMOUNT TO WS-FMT-TOTAL
           DISPLAY "  Total Records: " WS-RECORD-COUNT
           DISPLAY "  Total Staked:  " WS-FMT-TOTAL
           DISPLAY WS-HEADER-LINE
           DISPLAY "Press Enter to continue..."
           ACCEPT WS-PAUSE.
       
       FORMAT-HYPE.
           MOVE HYPE-ID TO WS-FMT-ID
           STRING HYPE-YEAR "-" HYPE-MONTH "-" HYPE-DAY DELIMITED BY SIZE
               INTO WS-FMT-DATE
           MOVE HYPE-AMOUNT TO WS-FMT-AMOUNT
           MOVE HYPE-APY TO WS-FMT-APY
           DISPLAY "  " WS-FMT-ID "  " WS-FMT-DATE "  " 
                   WS-FMT-AMOUNT "  " WS-FMT-APY "%  " HYPE-DESC.
       
      *---------------------------------------------------------------*
      * Delete Record Menu                                            *
      *---------------------------------------------------------------*
       DELETE-MENU.
           DISPLAY WS-BLANK-LINE
           DISPLAY "=================================================="
           DISPLAY "              DELETE RECORD                       "
           DISPLAY "=================================================="
           DISPLAY "  1. Delete Expense"
           DISPLAY "  2. Delete Deposit"
           DISPLAY "  3. Delete HYPE Stake"
           DISPLAY "  4. Back"
           DISPLAY "--------------------------------------------------"
           DISPLAY "Enter choice (1-4): " WITH NO ADVANCING
           ACCEPT WS-CHOICE
           
           EVALUATE WS-CHOICE
               WHEN 1
                   PERFORM DELETE-EXPENSE
               WHEN 2
                   PERFORM DELETE-DEPOSIT
               WHEN 3
                   PERFORM DELETE-HYPE
               WHEN 4
                   CONTINUE
               WHEN OTHER
                   DISPLAY "Invalid choice. Press Enter to continue..."
                   ACCEPT WS-PAUSE
           END-EVALUATE.
       
      *---------------------------------------------------------------*
      * Delete Expense                                                *
      *---------------------------------------------------------------*
       DELETE-EXPENSE.
           DISPLAY "Enter Expense ID to delete: " WITH NO ADVANCING
           ACCEPT WS-DELETE-ID
           
           MOVE 'N' TO WS-EOF
           MOVE 'N' TO WS-FOUND
           OPEN INPUT EXPENSE-FILE
           PERFORM UNTIL WS-EOF = 'Y'
               READ EXPENSE-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF
                   NOT AT END
                       IF EXP-ID = WS-DELETE-ID
                           MOVE 'Y' TO WS-FOUND
                       END-IF
               END-READ
           END-PERFORM
           CLOSE EXPENSE-FILE
           
           IF WS-FOUND = 'Y'
               STRING "sed -i '/^" WS-DELETE-ID "/d' expenses.dat"
                   DELIMITED BY SIZE INTO WS-SYSTEM-CMD
               CALL "SYSTEM" USING WS-SYSTEM-CMD
               DISPLAY "Expense deleted successfully."
           ELSE
               DISPLAY "Expense ID not found."
           END-IF
           
           DISPLAY "Press Enter to continue..."
           ACCEPT WS-PAUSE.
       
      *---------------------------------------------------------------*
      * Delete Deposit                                                *
      *---------------------------------------------------------------*
       DELETE-DEPOSIT.
           DISPLAY "Enter Deposit ID to delete: " WITH NO ADVANCING
           ACCEPT WS-DELETE-ID
           
           MOVE 'N' TO WS-EOF
           MOVE 'N' TO WS-FOUND
           OPEN INPUT DEPOSIT-FILE
           PERFORM UNTIL WS-EOF = 'Y'
               READ DEPOSIT-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF
                   NOT AT END
                       IF DEP-ID = WS-DELETE-ID
                           MOVE 'Y' TO WS-FOUND
                       END-IF
               END-READ
           END-PERFORM
           CLOSE DEPOSIT-FILE
           
           IF WS-FOUND = 'Y'
               STRING "sed -i '/^" WS-DELETE-ID "/d' deposits.dat"
                   DELIMITED BY SIZE INTO WS-SYSTEM-CMD
               CALL "SYSTEM" USING WS-SYSTEM-CMD
               DISPLAY "Deposit deleted successfully."
           ELSE
               DISPLAY "Deposit ID not found."
           END-IF
           
           DISPLAY "Press Enter to continue..."
           ACCEPT WS-PAUSE.
       
      *---------------------------------------------------------------*
      * Delete HYPE Stake                                             *
      *---------------------------------------------------------------*
       DELETE-HYPE.
           DISPLAY "Enter HYPE Stake ID to delete: " WITH NO ADVANCING
           ACCEPT WS-DELETE-ID
           
           MOVE 'N' TO WS-EOF
           MOVE 'N' TO WS-FOUND
           OPEN INPUT HYPE-FILE
           PERFORM UNTIL WS-EOF = 'Y'
               READ HYPE-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF
                   NOT AT END
                       IF HYPE-ID = WS-DELETE-ID
                           MOVE 'Y' TO WS-FOUND
                       END-IF
               END-READ
           END-PERFORM
           CLOSE HYPE-FILE
           
           IF WS-FOUND = 'Y'
               STRING "sed -i '/^" WS-DELETE-ID "/d' hype-stakes.dat"
                   DELIMITED BY SIZE INTO WS-SYSTEM-CMD
               CALL "SYSTEM" USING WS-SYSTEM-CMD
               DISPLAY "HYPE stake deleted successfully."
           ELSE
               DISPLAY "HYPE Stake ID not found."
           END-IF
           
           DISPLAY "Press Enter to continue..."
           ACCEPT WS-PAUSE.
       
      *---------------------------------------------------------------*
      * Reset Database                                                *
      *---------------------------------------------------------------*
       RESET-DATABASE.
           DISPLAY WS-BLANK-LINE
           DISPLAY "WARNING: This will delete ALL records."
           DISPLAY "Type 'YES' to confirm: " WITH NO ADVANCING
           ACCEPT WS-INPUT-CATEGORY
           
           IF WS-INPUT-CATEGORY = 'YES'
               OPEN OUTPUT EXPENSE-FILE
               CLOSE EXPENSE-FILE
               OPEN OUTPUT DEPOSIT-FILE
               CLOSE DEPOSIT-FILE
               OPEN OUTPUT HYPE-FILE
               CLOSE HYPE-FILE
               MOVE 1 TO WS-NEXT-ID
               MOVE 1 TO WS-NEXT-DEP-ID
               MOVE 1 TO WS-NEXT-HYPE-ID
               DISPLAY "All databases reset."
           ELSE
               DISPLAY "Reset cancelled."
           END-IF
           
           DISPLAY "Press Enter to continue..."
           ACCEPT WS-PAUSE.
