import ballerina/config;
import ballerina/http;
import ballerina/io;
import ballerina/log;

listener http:Listener httpListener = new (9090);

@http:ServiceConfig {
    basePath: "/medical",
    cors: {
        allowOrigins: [config:getAsString("SERVER_URL")]
    }
}

service PatientData on httpListener {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/patients"
    }
    resource function addPatientPersonalRecord(http:Caller caller, http:Request req) {
        http:Response response = new;
        string patientName = "Tina";
        int phoneNo = 736282936;
        string emailId = "tina@gmail.com";
        json addPatientRecord = createPatientRecord(patientName, phoneNo, emailId);
        response.setPayload(<@untainted>addPatientRecord);
        var result = caller->respond(response);
        handleError(result);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/patients/medicine/{patientId}"
    }
    resource function addPatientMedicalRecord(http:Caller caller, http:Request req, int patientId) {
        http:Response response = new;
        string doctorName = "Dr.Jane";
        string disease = "Hand Pain";
        string medicine = "Balm";

        json addPatientRecord = createMedicalRecord(patientId, doctorName, disease, medicine);
        response.setPayload(<@untainted>addPatientRecord);
        var result = caller->respond(response);
        handleError(result);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/patients"
    }
    resource function getAllPatientRecords(http:Caller caller, http:Request req) {
        var i = getMedicalRecordId(19);
        http:Response response = new;
        json allPatientRecord = retrieveAllPatientDetails();
        response.setPayload(<@untainted>allPatientRecord);
        var result = caller->respond(response);
        handleError(result);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/patients/{patientId}"
    }
    resource function getIndividualPatientPersonalRecord(http:Caller caller, http:Request req, int patientId) {
        http:Response response = new;
        if (patientId > 0) {
            json patientRecord = retrievePersonalRecordsById(patientId);
            response.setPayload(<@untainted>patientRecord);
            // Send a response back to the caller.
            var result = caller->respond(response);
            handleError(result);
        }
        else {
            log:printError("No patient Id has been provided...");
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/patients/medicine/{patientId}"
    }
    resource function getIndividualPatientMedicalRecord(http:Caller caller, http:Request req, int patientId) {
        http:Response response = new;
        io:println("Patient Id: ", patientId.toString());
        if (patientId > 0) {
            json patientRecord = retrieveMedicalRecordsById(patientId);
            response.setPayload(<@untainted>patientRecord);
            // Send a response back to the caller.
            var result = caller->respond(response);
            handleError(result);
        }
        else {
            log:printError("No patient Id has been provided...");
        }
    }
}

function handleError(error? result) {
    if (result is error) {
        log:printError(result.reason(), err = result);
    }
}
