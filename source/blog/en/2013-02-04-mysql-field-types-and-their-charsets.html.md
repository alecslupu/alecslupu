---

title: Mysql field types and their charsets
date: 2013-02-04 00:00 UTC
tags: 

---

When having to administer a big database having tables that contains millions  of rows, a big issue emerges. Optimizing the tables and the data stored.

A short version would tempt me to say: Don’t use the utf8 encoding for all the table. Use it for the damn fields where you really need it.

Longer version would require some calculus to be performed, and that would lead to a better understanding of what happens in a MySQL server.

When varchar is it used, the storage engine, allocate exactly the amount of bytes required to store the value, no matter the charset. However during the creation of the temporary tables and internal buffers (during joins, ordering, basic reading from the storage and other operations), the maximum amount of bytes for the column is allocated.

This means is you have a column that is Varchar(255) utf8, and you write a single letter in it, the disk will need just 2 bytes  to store it: 1 byte for its length and 1 byte to store the value. The issue becomes trickier, when you need to fetch that value, as MySQL not knowing what it is stored in that field, will allocate 768 bytes (you have read right 768… 256 bytes the length of the field * 3 bytes per utf8 character).

Assume you have a table that contains 2 columns of type varchar(255) utf8 and you might run a query like this:

    SELECT column1, column2 FROM table1 ORDER BY column1 DESC;

If you don’t have index on column1 and the table has 1 Million rows, MySQL would require to create a temporary table to do the sorting, which would lead to a temporary table of something like 1.43 Gb. The calculus is simple:

    768 (Bytes) *  2 (columns) * 1.000.000 (rows) = 1536000000 Bytes

which would give a roughly 1.43 Gigabytes of temporary table on disk.

If you have values that are actually that long, it makes sense, but if the maximum length is around 30 – 50 (let’s consider a username or a password or even an email field) the temporary table would be roughly around 290 Megabytes

    150 (Bytes) * 2 (columns) * 1000000 (records) = 300000000 Bytes 

which is a give a roughly 290 Megabytes.

It is obvious that 290 Megabytes are faster to read than a 1.43 Gigabytes.

Of course this could be pushed a little bit more, and if you don’t need utf8 encoding, you could  switch to latin1 which would mean around 95 Megabytes.

The above stuff is valid even you have a table of 20 Megabytes in size on disk.

Lessons that i am trying to express:

* use the charset you need!
* use the length of varchar in a responsible matter, don’t make it just “as much as possible”

Read more about: [MySQL Storage Requirements](http://dev.mysql.com/doc/refman/5.1/en/storage-requirements.html)

This post is written with help from my friend: [Rene Cannao](http://www.linkedin.com/in/renecannao)
