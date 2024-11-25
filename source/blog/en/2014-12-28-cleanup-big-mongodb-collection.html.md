---

title: Cleanup Big mongodb Collection
date: 2014-12-28 00:00 UTC
tags: 
category: "MongoDB" 

---

Recently i  have come across one small problem that i needed to fix. I had many records in a DB that i do not needed. I could not delete the entire collection, as i needed some of the records to be left alone. I have come up with this script, which allows me to delete records as I need.
    
    query = {
      created_at: {
        "$gte": new ISODate("2012-11-01T00:00:00Z"), 
        "$lt":  new ISODate("2012-12-01T00:00:00Z")
      }
    }
    
    items = db.<COLLECTION>.find(query).count();
    count = 0;
    batches =  parseInt(items / 1000);
    
    for (var i = 0; i < batches; i++) {
      print("Remaining: "+ parseInt(batches-i));
      db.<COLLECTION>.find(query).skip(count).limit(1000).forEach(function(p) {
        if (p.has_transaction && p.has_transaction == 1) {
          count++;
        } else {
          db.<MY BACKUP COLLECTION>.insert(p);
          db.<COLLECTION>.remove(p,1);
        }
      });
    }
    print(db.<COLLECTION>.find(query).count());
