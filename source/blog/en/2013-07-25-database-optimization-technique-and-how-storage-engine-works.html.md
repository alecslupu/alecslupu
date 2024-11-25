---

title: Database optimization technique and how storage engine works
date: 2013-07-25 00:00 UTC
image: /uploads/pagination.png
tags: 
category: "MySQL" 

---

Today i was discussing with a colleague of mine about a mysql database optimization technique, and some of the things i have learned about how mysql works on big table datasets. This article is not about “mysql”, is not about “Mongodb”, but more about the principle behind of it.

I will try to give you an idea about this using i using a book library example.

In any database engine you might have tables / collections that have million of rows, which needs to be sorted, ordered, filtered using conditions, and every time is a pain finding the right solutions.

### I have indexes, so is not a problem for me.

Well, if you’re reading this, then you might be wrong. First of all, if it is a query (and by query i mean any SQL / NoSQL statement meant to retrieve informations from the table) that is not ran on a constant basis, then most probably, your database engine does not have it cached. This means every time you’ll run that query the database engine will actually look in the store and actually filter all of your statements.

### Yes, but i am running statements using indexes …

Well … imagine that you’re in a library, and you ask the librarian to give you a certain book, knowing just the author. He will leave the office and go to search your book, knowing just a fragment of the specs. He will know that he needs to go to a certain row, but will not know which shelf, or what is the position of the book, so he will lose some time to read all those authors in that shelf, until he provides you the book.

This is happening in any Database engine, when you ask for a book that is not read too often.

Now imagine that you’re asking a book that was just returned by another reader. Now, the librarian might have not put the book back the shelf, so, he might give you faster because is just few meters away.

### Yeah… but the database engine is using “index tables”… there are pointers … etc

Well … yeah and no … imagine that you already know that the book is on a row and a shelf… you’ll still lose time by moving there, and also, searching on that shelf. The story is more like the one above.

### Ok … might get it … but how can i get a random record?

Well, in MySQL and other SQL languages you might do something like this :

    SELECT @v:=RAND() * (SELECT MAX(id) FROM your_table)

then:

    SELECT * FROM your_table WHERE  
        id > @v AND  the_rest_of_your_condition = 'something';

in MySQL RAND() function will always return a real number between 0 and 1, which means that any number will get generated will be actually between record 1 and your MAX(id).

This kind of hack is useful when your need to perform a query like…

    SELECT * FROM your_table WHERE your_condition = 'something' ORDER BY RAND();

At this very moment i don’t know how could you achieve that in a NoSQL engine.

### Well my problem is a pagination issue.

![Pagination](/uploads/pagination.png)

Good luck with that! Maybe you have something like:

    SELECT COUNT(SELECT * FROM my_table)

to find the number of rows that you have in your database… Well That’s bad … a mysql database optimization technique would be to use [CALC_FOUND_ROWS](http://dev.mysql.com/doc/refman/5.0/en/information-functions.html#function_found-rows) function call which might solve your issue like this:

    SELECT CALC_FOUND_ROWS * FROM my_table WHERE my_conditions = '1' LIMIT 0, 10;

Then you can use

    SELECT FOUND_ROWS()

However, your problem is still not fixed … On big datasets, you will still have a MySQL issue when using OFFSET or LIMIT. A query like:

    SELECT * FROM my_table LIMIT 10000, 10;

is similar with

    SELECT * FROM my_table OFFSET 10000 LIMIT 10;

Which in MySQL, will mean that the storage engine will actually load in memory and read 10010 rows. And once the offset gets higher, and higher, so the time waiting for the response will increase.

Those are just 2 optimisations that you can perform at least on MYSQL to get a faster response. There are more ways to optimize your mysql queries, but, because is not a “one size fits all” solution, i cannot speak about them, as i did not encountered them … YET.
