
mvn clean package

if [ $? -eq 0 ];then
	echo "mvn clean package Success. Redeploy 'testwebapp'"
	systemctl stop tomcat
	rm -rf /root/board_webpage/tomcat/tomcat_dir/webapps/testwebapp*
	cp target/testwebapp.war /root/board_webpage/tomcat/tomcat_dir/webapps/testwebapp.war
	systemctl restart tomcat
	echo "Redeploy 'testwebapp' Success"
fi	
