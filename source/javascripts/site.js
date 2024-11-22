// This is where it all goes :)

document.addEventListener("DOMContentLoaded", function(event) {
    const text = document.querySelectorAll('.reversed-text');
    text.forEach((element) => {
        element.textContent = element.textContent.split('').reverse().join('');
    })
});