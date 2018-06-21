# Add Gravitee MongoDB user
mongo admin -u MONGO_ROOT_USER -p MONGO_ROOT_PASSWORD
use GRAVITEE_MONGO_DBNAME;
var user = {
 "user" : "GRAVITEE_MONGO_USERNAME",
 "pwd" : "GRAVITEE_MONGO_PASSWORD",
 roles : [
     {
         "role" : "readWrite",
         "db" : "GRAVITEE_MONGO_DBNAME"
     }
 ]
}
db.createUser(user);
exit
