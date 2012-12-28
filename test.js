// Log results of a test in a table
function log_result(test_name, test_status, error_msg) {
	var table = document.getElementById("test-results");
	var rowCount = table.rows.length;
	var row = table.insertRow(rowCount);

	var cell1 = row.insertCell(0);
	cell1.innerHTML = test_name;

	var cell2 = row.insertCell(1);
	cell2.innerHTML = test_status;
	cell2.className = (test_status == "Passed") ? "pass" : "fail";

	var cell3 = row.insertCell(2);
	cell3.innerHTML = error_msg;
}

// Encode input and check if it matches output
function test_encode(test_name, input, format, output) {
	var test_status = "Failed";
	var error_msg = "";

	if (headlineEncode(input, format) == output) {
		test_status = "Passed";
	} else {
		error_msg = 'Test failed with input "' + input + '" and format "' + format + '". Expected output was "' + output + '" and actual output was "' + headlineEncode(input, format) + '"';
	}

	log_result(test_name, test_status, error_msg);
}

// Decode input and check if it matches output
function test_decode(test_name, input, output) {
	var test_status = "Failed";
	var error_msg = "";

	if (headlineDecode(input) == output) {
		test_status = "Passed";
	} else {
		error_msg = 'Test failed with input "' + input + '". Expected output was "' + output + '" and actual output was "' + headlineDecode(input) + '"';
	}

	log_result(test_name, test_status, error_msg);
}

// Check that encoding then decoding produces the original result
// decode(encode(x)) == x for all 00 <= x <= ff
function test_symmetry(format) {
	var result = "Passed";
	var error_msg = "";
	for (var i = 0; i < 256; ++i) {
		if (("0" + i.toString(16)).slice(-2) != headlineDecode(headlineEncode(("0" + i.toString(16)).slice(-2), format))) {
			result = "Failed";
			error_msg = "Failed to get the same value of " + ("0" + i.toString(16)).slice(-2) + " after encoding then decoding.";
			break;
		}
	}
	log_result("Reversible for " + format, result, error_msg);
}
