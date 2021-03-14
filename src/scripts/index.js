var parser = require("./peg.pegjs");

const input = document.getElementById("input");
const output = document.getElementById("output");
const extraOutput = document.getElementById("extraOutput");

input.addEventListener("input", (e) => {
    const result = parseValue(e.target.value);
    try {
        const result = parser.parse(input.value);
        output.classList.remove("error");
        output.innerText = JSON.stringify(result);
    } catch (err) {
        output.classList.add("error");
        output.innerText = JSON.stringify(err.message);
    }
});

function parseValue(input) {
    try {
        const result = parser.parse(input);
        console.log(input, result);
        return {
            input,
            type: "result",
            message: JSON.stringify(result),
        };
    } catch (err) {
        return {
            input,
            type: "error",
            message: err.message,
        };
    }
}
input.value = "hsl(0,0,1)";
input.dispatchEvent(new Event("input"));

const tests = ["#ff0000", "hsl(0,0,1)", "hsl(360,0,0)"];

extraOutput.innerHTML = tests
    .map((test) => {
        const result = parseValue(test);

        return `
            <div class="${result.type}">
                <strong>${result.input}</strong><br>
                ${result.message}
            </div>`;
    })
    .join("");
