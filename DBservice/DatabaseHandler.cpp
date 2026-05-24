#include "DatabaseHandler.h"
#include <iostream>

DatabaseHandler::DatabaseHandler() : db(nullptr) {
    // Ensuring it targets the subfolder as previously discussed
    std::string dbPath = "DatabaseFolder/CollectedData.db"; 
    
    if (sqlite3_open(dbPath.c_str(), &db) != SQLITE_OK) {
        std::cerr << "Error opening database: " << sqlite3_errmsg(db) << std::endl;
        db = nullptr;
    } else {
        if (initializeTable()) {
            seedDummyDataIfNeeded();
        }
    }
}

DatabaseHandler::~DatabaseHandler() {
    if (db) {
        sqlite3_close(db);
    }
}

bool DatabaseHandler::initializeTable() {
    if (!db) return false;

    std::string query = "CREATE TABLE IF NOT EXISTS Students ("
                        "ID INTEGER PRIMARY KEY AUTOINCREMENT, "
                        "FullName TEXT NOT NULL, "
                        "CommuneZone TEXT, "
                        "Date TEXT, "
                        "AcademicInterest TEXT);";
    
    char* errMsg = nullptr;
    if (sqlite3_exec(db, query.c_str(), nullptr, nullptr, &errMsg) != SQLITE_OK) {
        std::cerr << "Failed to create table: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }
    return true;
}

// Automatically called upon successful connection/table setup
void DatabaseHandler::seedDummyDataIfNeeded() {
    if (!db) return;

    // 1. Check if the table is empty
    std::string checkQuery = "SELECT COUNT(*) FROM Students;";
    sqlite3_stmt* stmt;
    int count = 0;

    if (sqlite3_prepare_v2(db, checkQuery.c_str(), -1, &stmt, nullptr) == SQLITE_OK) {
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            count = sqlite3_column_int(stmt, 0);
        }
    }
    sqlite3_finalize(stmt);

    // 2. If empty, insert the initial dummy record
    if (count == 0) {
        std::cout << "Database is empty. Seeding initial dummy record..." << std::endl;
        
        StudentData dummyRecord;
        dummyRecord.fullName = "Axl";
        dummyRecord.communeZone = "Comuna 14 - Poblado";
        dummyRecord.date = "2026-05-24";
        dummyRecord.academicInterest = "Telematics";

        createRecord(dummyRecord);
    }
}

// CREATE
bool DatabaseHandler::createRecord(StudentData& student) {
    if (!db) return false;

    std::string query = "INSERT INTO Students (FullName, CommuneZone, Date, AcademicInterest) VALUES (?, ?, ?, ?);";
    sqlite3_stmt* stmt;

    if (sqlite3_prepare_v2(db, query.c_str(), -1, &stmt, nullptr) != SQLITE_OK) {
        return false;
    }

    sqlite3_bind_text(stmt, 1, student.fullName.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, student.communeZone.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 3, student.date.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 4, student.academicInterest.c_str(), -1, SQLITE_TRANSIENT);

    bool success = (sqlite3_step(stmt) == SQLITE_DONE);
    sqlite3_finalize(stmt);

    if (success) {
        student.id = static_cast<int>(sqlite3_last_insert_rowid(db));
    }

    return success;
}

// READ (by ID)
StudentData DatabaseHandler::readRecordById(int id) {
    StudentData student;
    if (!db) return student;

    std::string query = "SELECT ID, FullName, CommuneZone, Date, AcademicInterest FROM Students WHERE ID = ?;";
    sqlite3_stmt* stmt;

    if (sqlite3_prepare_v2(db, query.c_str(), -1, &stmt, nullptr) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, id);

        if (sqlite3_step(stmt) == SQLITE_ROW) {
            student.id = sqlite3_column_int(stmt, 0);
            student.fullName = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1));
            student.communeZone = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 2));
            student.date = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 3));
            student.academicInterest = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 4));
        }
    }
    sqlite3_finalize(stmt);
    return student; 
}

// UPDATE (by ID)
bool DatabaseHandler::updateRecordById(int id, const StudentData& updatedStudent) {
    if (!db) return false;

    std::string query = "UPDATE Students SET FullName = ?, CommuneZone = ?, Date = ?, AcademicInterest = ? WHERE ID = ?;";
    sqlite3_stmt* stmt;

    if (sqlite3_prepare_v2(db, query.c_str(), -1, &stmt, nullptr) != SQLITE_OK) {
        return false;
    }

    sqlite3_bind_text(stmt, 1, updatedStudent.fullName.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, updatedStudent.communeZone.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 3, updatedStudent.date.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 4, updatedStudent.academicInterest.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(stmt, 5, id);

    bool success = (sqlite3_step(stmt) == SQLITE_DONE);
    sqlite3_finalize(stmt);
    return success;
}

// DELETE (by ID)
bool DatabaseHandler::deleteRecordById(int id) {
    if (!db) return false;

    std::string query = "DELETE FROM Students WHERE ID = ?;";
    sqlite3_stmt* stmt;

    if (sqlite3_prepare_v2(db, query.c_str(), -1, &stmt, nullptr) != SQLITE_OK) {
        return false;
    }

    sqlite3_bind_int(stmt, 1, id);

    bool success = (sqlite3_step(stmt) == SQLITE_DONE);
    sqlite3_finalize(stmt);
    return success;
}

// READ ALL
std::vector<StudentData> DatabaseHandler::getAllRecords() {
    std::vector<StudentData> records;
    if (!db) return records;

    std::string query = "SELECT ID, FullName, CommuneZone, Date, AcademicInterest FROM Students;";
    sqlite3_stmt* stmt;

    if (sqlite3_prepare_v2(db, query.c_str(), -1, &stmt, nullptr) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            StudentData student;
            student.id = sqlite3_column_int(stmt, 0);
            student.fullName = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1));
            student.communeZone = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 2));
            student.date = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 3));
            student.academicInterest = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 4));
            records.push_back(student);
        }
    }
    sqlite3_finalize(stmt);
    return records;
}