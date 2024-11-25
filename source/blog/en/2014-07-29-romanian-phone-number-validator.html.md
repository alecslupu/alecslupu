---

title: Romanian Phone Number validator
date: 2014-07-29 00:00 UTC
tags: 
category: "Javascript" 

---

Recently i had to implement a Romanian Phone Number validator… and i have managed to implement it as a method of the [jQuery Validation Plugin](http://jqueryvalidation.org/).

here is the whole method

    $.validator.addMethod("phoneRO", function(phone_number, element) {
      phone_number = phone_number.replace(/\(|\)|\s+|-/g, "");

      return this.optional(element) || phone_number.length > 9 &&
    phone_number.match(/^(?:(?:(?:00\s?|\+)40\s?|0)(?:7\d{2}\s?\d{3}\s?\d{3}|(21|31)\d{1}\s?\d{3}\s?\d{3}|((2|3)[3-7]\d{1})\s?\d{3}\s?\d{3}|(8|9)0\d{1}\s?\d{3}\s?\d{3}))$/);
    }, "Please specify a valid romanian phone number");

The ReGex of interest is:

    /^(?:(?:(?:00\s?|\+)40\s?|0)(?:7\d{2}\s?\d{3}\s?\d{3}|(21|31)\d{1}\s?\d{3}\s?\d{3}|((2|3)[3-7]\d{1})\s?\d{3}\s?\d{3}|(8|9)0\d{1}\s?\d{3}\s?\d{3}))$/

Some of the formats this ReGex is able to recognise are:

00 40 722 000 000

00 40 218 032 329

00 40 243 253 398

00 40 343 254 398

00 40 800 801 227

00 40 318 032 329

0722 000 000

0800 801 227

0800 801227

0318 032 329

Have a try: [http://rubular.com/r/2ufyprKWGz](http://rubular.com/r/2ufyprKWGz)
