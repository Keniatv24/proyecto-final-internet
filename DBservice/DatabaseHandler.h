#pragma once

#include <string>
#include <vector>
#include <sqlite3.h>

struct StudentData {
    int id = -1; 
    std::string fullName;
    std::string communeZone;
    std::string date;
    std::string academicInterest;
};

class DatabaseHandler {
public:
    DatabaseHandler();
    ~DatabaseHandler();

    bool createRecord(StudentData& student); 
    StudentData readRecordById(int id);
    bool updateRecordById(int id, const StudentData& updatedStudent);
    bool deleteRecordById(int id);

    std::vector<StudentData> getAllRecords();

private:
    sqlite3* db;
    bool initializeTable();
    void seedDummyDataIfNeeded(); // New automatic seeding method
};