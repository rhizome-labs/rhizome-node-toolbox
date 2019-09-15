1. cd {Prep ROOT Directory}

2. wget https://download.solidwallet.io/backup/ZiconPrepNet/zicon_restore.sh

3. chmod +x zicon_restore.sh

4. docker-compose down

5. sudo sh zicon_restore.sh
---------------------------- Backup List  -----------------------------
1:20190911/ZiconPrepNet_BH4933_data-20190911_1700.tar.gz
2:20190911/ZiconPrepNet_BH4280_data-20190911_1638.tar.gz
-----------------------------------------------------------------------

6. Backup File Num Select : 1
-rw-r--r-- 1 root root 372211 Jul  2 10:00 ZiconPrepNet_BH4933_data-20190911_1700.tar.gz

------------------------ Prep DB Restore Start -------------------------


7. P-Rep Public IP : xxx.xxx.xxx.xxx


.storage/db_CHANGEIP:7100_icon_dex/030373.ldb
.storage/db_CHANGEIP:7100_icon_dex/030563.ldb
.storage/db_CHANGEIP:7100_icon_dex/030583.ldb
.storage/db_CHANGEIP:7100_icon_dex/030971.ldb
------------------------- Prep DB Restore END -------------------------

8. docker-compose up -d
