#include "DatabaseHandler.h"
#include <iostream>

int main() {
    std::cout << "Initializing database connection..." << std::endl;
    DatabaseHandler db;

    std::cout << "\n--- Current Database Records (Before Test) ---" << std::endl;
    std::vector<StudentData> allStudents = db.getAllRecords();
    
    if (allStudents.empty()) {
        std::cout << "No records found." << std::endl;
    } else {
        for (const auto& student : allStudents) {
            std::cout << "ID: " << student.id 
                      << " | Name: " << student.fullName 
                      << " | Zone: " << student.communeZone 
                      << " | Interest: " << student.academicInterest << std::endl;
        }
    }

    std::cout << "\n--- Starting Add -> Print -> Delete Test ---" << std::endl;

    // 1. Create a new temporary registry
    StudentData tempRecord;
    tempRecord.fullName = "Test User";
    tempRecord.communeZone = "Comuna 10 - La Candelaria";
    tempRecord.date = "2026-05-24";
    tempRecord.academicInterest = "Temporary Data Testing";

    std::cout << "Attempting to create temporary record..." << std::endl;
    
    if (db.createRecord(tempRecord)) {
        std::cout << "[SUCCESS] Record created! SQLite assigned ID: " << tempRecord.id << std::endl;

        // 2. Read it back from the DB and print it
        StudentData fetchedRecord = db.readRecordById(tempRecord.id);
        if (fetchedRecord.id != -1) {
            std::cout << "\n[PRINT] Reading newly inserted record directly from DB:" << std::endl;
            std::cout << "        Name:     " << fetchedRecord.fullName << std::endl;
            std::cout << "        Zone:     " << fetchedRecord.communeZone << std::endl;
            std::cout << "        Date:     " << fetchedRecord.date << std::endl;
            std::cout << "        Interest: " << fetchedRecord.academicInterest << std::endl;
        } else {
            std::cout << "[ERROR] Could not read the record from the DB." << std::endl;
        }

        // 3. Eliminate the registry
        std::cout << "\nAttempting to delete record ID " << tempRecord.id << "..." << std::endl;
        
        if (db.deleteRecordById(tempRecord.id)) {
            std::cout << "[SUCCESS] Record deleted successfully." << std::endl;
        } else {
            std::cout << "[ERROR] Failed to delete the record." << std::endl;
        }

        // 4. Verify the elimination
        StudentData verifyDelete = db.readRecordById(tempRecord.id);
        if (verifyDelete.id == -1) {
            std::cout << "[VERIFY] Confirmed: Record ID " << tempRecord.id << " no longer exists in the database." << std::endl;
        } else {
            std::cout << "[VERIFY] Warning: Record was not actually removed!" << std::endl;
        }

    } else {
        std::cout << "[ERROR] Failed to create the temporary record." << std::endl;
    }

    return 0;
}