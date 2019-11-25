import ballerina/config;
import ballerina/io;
import ballerina/jsonutils;
import ballerinax/java.jdbc;

jdbc:Client patientDB = new ({
    url: config:getAsString("URL"),
    username: config:getAsString("USERNAME"),
    password: config:getAsString("PASSWORD"),
    poolOptions: {maximumPoolSize: 10},
    dbOptions: {useSSL: false}
});

string getAllPatientsQuery = "SELECT * FROM patient";
string getPersonalPatientQuery = "SELECT * FROM patient WHERE patient_id=?";
string getAllMedicalRecordsForSpecificPatientQuery = "SELECT * FROM patient p, medicine m WHERE p.patient_id = m.patient_id AND p.patient_id = ?";

# Description
# Create new patient record with patient Id, patient name, phone number and email Id. The patient record Id will be suto incremented from the DB side.
# + patientName - patientName Parameter Description 
# + phoneNo - phoneNo Parameter Description 
# + emailId - emailId Parameter Description
# + return - Return Value Description
function createPatientRecord(string patientName, int phoneNo, string emailId) returns int {
    var output = patientDB->update("INSERT INTO patient(patient_name, phone_number, email_id) VALUES (?, ?, ?)", patientName, phoneNo, emailId);
    return handleUpdate(output, "Creating patient record...");
}

# Description
# Get the maximum medical record Id available in the medicine table and create the new Id by adding 1 to the existing maximum record Id.
# + patientId - patientId Parameter Description 
# + return - Return Value Description
function getMedicalRecordId(int patientId) returns int {
    int newMedicalRecordId = 0;
    var maxIdProcedure = patientDB->update("CREATE PROCEDURE autoInc (IN pId INT, OUT getMaxId INT)
                                            BEGIN
                                                    SELECT MAX(medical_record) INTO getMaxId
                                                    FROM medicine
                                                    WHERE patient_id = pId;
                                            END");
    jdbc:Parameter param1 = {sqlType: jdbc:TYPE_INTEGER, value: patientId, direction: jdbc:DIRECTION_IN};
    jdbc:Parameter param2 = {sqlType: jdbc:TYPE_INTEGER, direction: jdbc:DIRECTION_OUT};
    var maxIdCall = patientDB->call("{CALL autoInc(?,?)}", (), param1, param2);

    if (maxIdCall is () | table<record {}>) {
        newMedicalRecordId = <int>param2.value + 1;
        io:println("New Medical Record Id: ", newMedicalRecordId);
    }
    else {
        io:println("Unable to retrieve details for the requested query... ");
    }
    return newMedicalRecordId;
}

# Description
# Create medical records for the existing patients by providing the patinet Id, medical record Id, doctor name, disease and medicine.
# The medical record Id will be generated through getMedicalRecordId(patientId) method.
# + patientId - patientId Parameter Description 
# + doctorName - doctorName Parameter Description 
# + disease - disease Parameter Description 
# + medicine - medicine Parameter Description 
# + return - Return Value Description
function createMedicalRecord(int patientId, string doctorName, string disease, string medicine) returns int {
    int medicalRecordId = getMedicalRecordId(patientId);
    var output = patientDB->update("INSERT INTO medicine(patient_id, medical_record, doctor_name, disease, medicine) VALUES (?, ?, ?, ?, ?)", patientId, medicalRecordId, doctorName, disease, medicine);
    return handleUpdate(output, "Creating medicine record...");
}

# Description
# Get all the patients' details
# + return - Return Value Description
function retrieveAllPatientDetails() returns json {
    var patientRecord = patientDB->select(getAllPatientsQuery, ());
    if (patientRecord is table<record {}>) {
        var patientRecordJson = jsonutils:fromTable(patientRecord);
        return patientRecordJson;
    } else {
        error err = patientRecord;
        io:println("Unable to retrieve details for the requested query... : ", <string>err.detail()["message"]);
    }
}

# Description
# Get a particular patient's personal details by patient Id.
# + patientId - id Parameter Description 
# + return - Return Value Description
function retrievePersonalRecordsById(int patientId) returns json {
    var individualPatientPersonalRecord = patientDB->select(getPersonalPatientQuery, (), patientId);
    if (individualPatientPersonalRecord is table<record {}>) {
        var individualPatientPersonalRecordJson = jsonutils:fromTable(individualPatientPersonalRecord);
        io:println("Output length: ", individualPatientPersonalRecordJson.size);
        return individualPatientPersonalRecordJson;
    } else {
        error err = individualPatientPersonalRecord;
        io:println("Unable to retrieve details for the requested query... : ", <string>err.detail()["message"]);
    }
}

# Description
# Get a particular patient's medical details by patient Id.
# + patientId - id Parameter Description 
# + return - Return Value Description
function retrieveMedicalRecordsById(int patientId) returns json {
    var individualPatientMedicalRecord = patientDB->select(getAllMedicalRecordsForSpecificPatientQuery, (), patientId);
    if (individualPatientMedicalRecord is table<record {}>) {
        var individualPatientMedicalRecordJson = jsonutils:fromTable(individualPatientMedicalRecord);
        io:println("Output length: ", individualPatientMedicalRecordJson.size);
        return individualPatientMedicalRecordJson;
    } else {
        error err = individualPatientMedicalRecord;
        io:println("Unable to retrieve details for the requested query... : ", <string>err.detail()["message"]);
    }
}

// [
//     {
//         "patient_id": 1,
//         "patient_name": "Tina",
//         "phone_number": 736282936,
//         "email_id": "tina@gmail.com",
//         "MEDICINE.patient_id": 1,
//         "medical_record": 0,
//         "doctor_name": "Dr.Tom",
//         "disease": "Stomach Pain",
//         "medicine": "Asamothagam"
//     },
//     {
//         "patient_id": 1,
//         "patient_name": "Tina",
//         "phone_number": 736282936,
//         "email_id": "tina@gmail.com",
//         "MEDICINE.patient_id": 1,
//         "medical_record": 1,
//         "doctor_name": "Dr.Tom",
//         "disease": "Stomach Pain",
//         "medicine": "Asamothagam"
//     }
// ]

function retrieveMedicalRecordsByIdFormattedRespose(int patientId) {
    json output = retrieveMedicalRecordsById(patientId);
    json patinetDetails = {};
    json[] medicalRecords;
    io:println("Output length: ", output.size);

// foreach var medicalRecord in output {

// }
}

# Description
# Handles the sql query updates and returns the state of it.
# + returned - returned Parameter Description 
# + message - message Parameter Description 
# + return - Return Value Description
function handleUpdate(jdbc:UpdateResult | jdbc:Error returned, string message) returns int {
    int flag = -1;
    if (returned is jdbc:UpdateResult) {
        io:println(message, " status: ", returned.updatedRowCount);
        flag = returned.updatedRowCount;
    } else {
        error err = returned;
        io:println(message, " failed: ", <string>err.detail()["message"]);
    }
    return flag;
}
