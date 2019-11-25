import ballerina/io;
import ballerina/jsonutils;
import ballerina/crypto;
import ballerina/log;
import ballerinax/java;

string getLoginUserDetailsQuery = "SELECT * FROM users WHERE username=? AND password=?";
string getUsernameQuery = "SELECT * FROM users WHERE username=?";

# Description
# Authorize the login user by validating the login username and password against the values in the database
# + username - username Parameter Description
# + password - password Parameter Description
# + return - Return Value Description
function retrieveLoginUsersByUsernameAndPassword(string username, string password) returns string {
    string roleValue = "";

    var individualUserLoginRecord = patientDB->select(getLoginUserDetailsQuery, (), username, password);
    if (individualUserLoginRecord is table<record {}>) {
        json[] role = <json[]>jsonutils:fromTable(individualUserLoginRecord);
        io:println("Output length: ", role.length());

        if(role.length() == 1 ){
        	foreach json roleJson in role {
                roleValue = roleJson.role_name.toString();
                io:println(roleValue);
        	}
        }
        else{
            io:println("Unable to retrieve details for the requested query... : ");
        }

    } else {
        error err = individualUserLoginRecord;
        io:println("Unable to retrieve details for the requested query... : ", <string>err.detail()["message"]);
    }
    return roleValue;
}


# Description
# Create login user details and save it in the database
# + username - username Parameter Description
# + plain_password - plain_password Parameter Description
# + role - role Parameter Description
# + return - Return Value Description
function createLoginUserRecord(string username, string plain_password, string role) returns int{
    int flag = -1;
    if(!retrieveLoginUsersByUsername(username)){
        string password = generateSaltedHashValue(plain_password);
        io:println(password);
        var output = patientDB->update("INSERT INTO users(username, password, role_name) VALUES(?, ?, ?)", username, password, role);
        flag = handleUpdate(output, "Creating login user record...");
    }
    else{
        log:printError("Unable to create user details...");
    }

    return flag;

}

# Description
# Generate UUID value as the salt for hashed password
# + return - Return Value Description
function createRandomValue() returns handle = @java:Method {
    name: "randomUUID",
    class: "java.util.UUID"
} external;


# Description
# Generate the salted hashed password using the
# + raw_value - rawValue Parameter Description
# + return - Return Value Description
function generateSaltedHashValue(string raw_value) returns string{

    string salted_hash_password="";

    if(raw_value !== ""){
        var secure_random = createRandomValue();
        io:println(secure_random.toString());

        string raw = raw_value  + secure_random.toString();
        io:println(raw);
        byte[] inputArr = raw.toBytes();
        byte[] salted_hash_password_array= crypto:hashSha256(inputArr);
        salted_hash_password = salted_hash_password_array.toBase16().toString();
        io:println(salted_hash_password);
    }
    else{
        log:printError("Null value cannot be accepted...");
    }

    return salted_hash_password;

}

# Description
# Check if the username already exists in the database
# + username - username Parameter Description
# + return - Return Value Description
function retrieveLoginUsersByUsername(string username) returns boolean {
    boolean isUsernameExists = false;

    var individualUserLoginRecord = patientDB->select(getUsernameQuery, (), username);
    if (individualUserLoginRecord is table<record {}>) {
        json[] output = <json[]>jsonutils:fromTable(individualUserLoginRecord);
        io:println("Output length: ", output.length());

        if(output.length() == 1 ){
        	isUsernameExists = true;
        }
        else{
            isUsernameExists = false;
            io:println("The user already exists...  ");
        }

    } else {
        error err = individualUserLoginRecord;
        io:println("Unable to retrieve details for the requested query... : ", <string>err.detail()["message"]);
    }
    io:println("Flag "+isUsernameExists.toString());
    return isUsernameExists;
}
