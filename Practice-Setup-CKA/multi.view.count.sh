ls -1|while true
do
#brave='Brave\ Browser'
#avast='Avast\ Secure\ Browser'
#https://www.youtube.com/shorts/hr6NvGmZK2w
#URL=https://www.youtube.com/shorts/hr6NvGmZK2w
for b in safari firefox Blisk 
        do
                open -a $b  https://www.youtube.com/watch?v=SOu_0NSYejM & open -a $b  https://www.youtube.com/watch?v=SOu_0NSYejM & open -a $b  https://www.youtube.com/watch?v=SOu_0NSYejM & open -a $b  https://www.youtube.com/watch?v=SOu_0NSYejM & open -a $b  https://www.youtube.com/watch?v=SOu_0NSYejM
                #open -a $b https://www.youtube.com/shorts/hr6NvGmZK2w
sleep 35
ps -ef|grep -i $b |grep Contents|awk '{print $2}'|while read i; do kill -9 $i; done
done
done
