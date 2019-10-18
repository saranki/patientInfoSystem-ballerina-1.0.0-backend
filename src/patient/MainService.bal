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
        // Send a response back to the caller.
        var result = caller->respond(response);
        handleError(result);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/patients/medicine/{patientId}"
    }

    resource function addPatientMedicalRecord(http:Caller caller, http:Request req, int patientId) {
        http:Response response = new;
        int medicalId = 1;
        string doctorName = "Dr.Tom";
        string disease = "Stomach Pain";
        string medicine = "Asamothagam";

        json addPatientRecord = createMedicalRecord(patientId, medicalId, doctorName, disease, medicine);
        response.setPayload(<@untainted>addPatientRecord);
        // Send a response back to the caller.
        var result = caller->respond(response);
        handleError(result);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/patients"
    }

    // Resource functions are invoked with the HTTP caller and the incoming request as arguments.
    resource function getAllPatientRecords(http:Caller caller, http:Request req) {
        http:Response response = new;
        json allPatientRecord = retrieveAllPatientDetails();
        response.setPayload(<@untainted>allPatientRecord);
        // Send a response back to the caller.
        var result = caller->respond(response);
        handleError(result);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/patients/{patientId}"
    }

    // Resource functions are invoked with the HTTP caller and the incoming request as arguments.
    resource function getIndividualPatientPersonalRecord(http:Caller caller, http:Request req, int patientId) {
        http:Response response = new;
        io:println("Patient Id: ", patientId.toString());
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

    // Resource functions are invoked with the HTTP caller and the incoming request as arguments.
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
