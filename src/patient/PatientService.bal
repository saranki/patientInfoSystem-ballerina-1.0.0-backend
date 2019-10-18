import ballerina/io;
import ballerina/jsonutils;
import ballerinax/java.jdbc;

jdbc:Client patientDB = new ({
    url: "jdbc:mysql://localhost:3306/patientDB",
    username: "root",
    password: "Sara@wso2",
    poolOptions: {maximumPoolSize: 10},
    dbOptions: {useSSL: false}
});

string getAllPatientsQuery = "SELECT * FROM patient";
string getPersonalPatientQuery = "SELECT * FROM patient WHERE patient_id=?";
string getAllMedicalRecordsForSpecificPatientQuery = "SELECT * FROM patient p, medicine m WHERE p.patient_id = m.patient_id AND p.patient_id = ?";


function createPatientRecord(string patientName, int phoneNo, string emailId) {
    var output = patientDB->update("INSERT INTO patient(patient_name, phone_number, email_id) VALUES (?, ?, ?)", patientName, phoneNo, emailId);
    handleUpdate(output, "Creating patient record...");
}

function createMedicalRecord(int patientId, int medicalRecord, string doctorName, string disease, string medicine) {
    var output = patientDB->update("INSERT INTO medicine(patient_id, medical_record, doctor_name, disease, medicine) VALUES (?, ?, ?, ?, ?)", patientId, medicalRecord, doctorName, disease, medicine);
    handleUpdate(output, "Creating medicine record...");
}

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

function retrievePersonalRecordsById(int id) returns json {
    var individualPatientPersonalRecord = patientDB->select(getPersonalPatientQuery, (), id);
    if (individualPatientPersonalRecord is table<record {}>) {
        //var individualPatientRecordJson = json.convert(individualPatientRecord);
        var individualPatientPersonalRecordJson = jsonutils:fromTable(individualPatientPersonalRecord);
        return individualPatientPersonalRecordJson;
    } else {
        error err = individualPatientPersonalRecord;
        io:println("Unable to retrieve details for the requested query... : ", <string>err.detail()["message"]);
    }
}

function retrieveMedicalRecordsById(int id) returns json {
    var individualPatientMedicalRecord = patientDB->select(getAllMedicalRecordsForSpecificPatientQuery, (), id);
    if (individualPatientMedicalRecord is table<record {}>) {
        //var individualPatientRecordJson = json.convert(individualPatientRecord);
        var individualPatientMedicalRecordJson = jsonutils:fromTable(individualPatientMedicalRecord);
        return individualPatientMedicalRecordJson;
    } else {
        error err = individualPatientMedicalRecord;
        io:println("Unable to retrieve details for the requested query... : ", <string>err.detail()["message"]);
    }
}

function handleUpdate(jdbc:UpdateResult | jdbc:Error returned, string message) {
    if (returned is jdbc:UpdateResult) {
        io:println(message, " status: ", returned.updatedRowCount);
    } else {
        error err = returned;
        io:println(message, " failed: ", <string>err.detail()["message"]);
    }
}
