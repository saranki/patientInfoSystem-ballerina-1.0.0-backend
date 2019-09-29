import ballerina/io;
import ballerinax/java.jdbc;
import ballerina/jsonutils;

jdbc:Client patientDB = new({
        url: "jdbc:mysql://localhost:3306/patientDB",
        username: "root",
        password: "Sara@wso2",
        poolOptions: { maximumPoolSize: 10 },
        dbOptions: { useSSL: false }
});

public function main() {
    string getAllPatientsQuery = "SELECT * FROM patient";
    string getAllMedicalRecordsForSpecificPatient = "SELECT *
                                                     FROM patient p, medicine m
                                                     WHERE p.patient_id = m.patient_id AND
                                                     p.patient_id = ?";

    // Create patient record
    createPatientRecord("Tom", 989767678, "kate@gmail.com");
    io:println("--------------------------------------------------------- ");


    // Create medical record
    createMedicalRecord(6, 1, "Tim", "Fever", "Panadol");
    io:println("--------------------------------------------------------- ");


    // Retrieve all the patients' records
    getAllRecords(getAllPatientsQuery);
    io:println("--------------------------------------------------------- ");


    // Retrieve all the medical records of a particular patient
    getAllRecordsById(getAllMedicalRecordsForSpecificPatient, 1);

}

function createPatientRecord(string patientName, int phoneNo, string emailId){
    var output = patientDB->update("INSERT INTO patient(patient_name, phone_number, email_id) VALUES (?, ?, ?)", patientName, phoneNo, emailId);
    handleUpdate(output, "Creating patient record...");
}

function createMedicalRecord(int patientId, int medicalRecord, string doctorName, string disease, string medicine){
    var output = patientDB->update("INSERT INTO medicine(patient_id, medical_record, doctor_name, disease, medicine) VALUES (?, ?, ?, ?, ?)", patientId, medicalRecord, doctorName, disease, medicine);
    handleUpdate(output, "Creating medicine record...");
}

function getAllRecords(string query){
    var result = patientDB->select(query, ());
    if (result is table< record{} >) {
        json jsonConversionRet = jsonutils:fromTable(result);
        io:print("JSON: ");
        io:println(jsonConversionRet);
    } else {
        error err = result;
        io:println("Unable to retrieve details for the requested query... : ", <string> err.detail()["message"]);
    }
}

function getAllRecordsById(string query, int id){
    var result = patientDB->select(query, (), id);
    if (result is table< record{} >) {
        json jsonConversionRet = jsonutils:fromTable(result);
        io:print("JSON: ");
        io:println(jsonConversionRet);
    } else {
        error err = result;
        io:println("Unable to retrieve details for the requested query... : ", <string> err.detail()["message"]);
    }
}

function handleUpdate(jdbc:UpdateResult|jdbc:Error returned, string message) {
    if (returned is jdbc:UpdateResult) {
        io:println(message, " status: ", returned.updatedRowCount);
    } else {
        error err = returned;
        io:println(message, " failed: ", <string> err.detail()["message"]);
    }
}
