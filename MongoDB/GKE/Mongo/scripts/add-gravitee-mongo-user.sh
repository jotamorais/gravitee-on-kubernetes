# Add Gravitee MongoDB user
mongo admin -u main_admin -p abc123
use gravitee;
var user = {
 "user" : "gravitee",
 "pwd" : "gravitee123",
 roles : [
     {
         "role" : "readWrite",
         "db" : "gravitee"
     }
 ]
}
db.createUser(user);
exit
