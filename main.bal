import ballerinax/mysql;
import ballerina/http;
import ballerina/sql;
import ballerinax/mysql.driver as _;

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowCredentials: false,
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Authorization", "content-type", "Accept", "x-jwt-assertion"],
        maxAge: 84900
    }
}

// Define the Employee record type
type Employee record {
    int id;
    string name;
    string position;
    string department;
    decimal salary;
};

type DatabaseConfig record {| 
    string host; 
    string user; 
    string password; 
    string database; 
    int port; 
|};

// Load the database configuration from Ballerina.toml
configurable DatabaseConfig databaseConfig = ?;

// Create a new MySQL client using the configuration
final mysql:Client dbClient = check new (...databaseConfig);

// Define the HTTP service
service /employees on new http:Listener(8086) {

    // Get all employees
    resource function get all() returns Employee[]|error {
        stream<Employee, sql:Error?> result = dbClient->query(`SELECT * FROM employees`);
        return from var employee in result select employee;
    }

    // Get an employee by ID
    // Update this resource to match the required path structure
    resource function get id(int id) returns Employee|error {
        Employee employee = check dbClient->queryRow(`SELECT * FROM employees WHERE id = ${id}`);
        return employee;
    }

    // Add a new employee
    resource function post employee(Employee employee) returns string|error {
        _ = check dbClient->execute(`INSERT INTO employees (name, position, department, salary) VALUES (${employee.name}, ${employee.position}, ${employee.department}, ${employee.salary})`);
        return "Employee added successfully";
    }

    // Update an existing employee
    resource function put id(int id, Employee employee) returns string|error {
        _ = check dbClient->execute(`UPDATE employees SET name = ${employee.name}, position = ${employee.position}, department = ${employee.department}, salary = ${employee.salary} WHERE id = ${id}`);
        return "Employee updated successfully";
    }

    // Delete an employee
    resource function delete id(int id) returns string|error {
        _ = check dbClient->execute(`DELETE FROM employees WHERE id = ${id}`);
        return "Employee deleted successfully";
    }
}
