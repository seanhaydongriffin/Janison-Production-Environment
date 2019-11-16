#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseUpx=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;#RequireAdmin
;#AutoIt3Wrapper_usex64=n
#include <SQLite.au3>
#include <SQLite.dll.au3>
#include <Toast.au3>
#include <Octopus.au3>
#include <Confluence.au3>
#include <Date.au3>

Local $app_name = "Janison Production Environment"

; Authentication

Local $ini_filename = @ScriptDir & "\" & $app_name & ".ini"
_ConfluenceAuthenticationWithToast($app_name, "https://janisoncls.atlassian.net", $ini_filename)
_ConfluenceAuthenticationWithToast($app_name, "https://janisoncls.atlassian.net", $ini_filename)
_OctopusDomainSet("https://octopus.janison.com.au")
_OctopusLogin("API-YGNPW8QJMAS38DEY9ASYENSWQ")

; Page header

$storage_format = '<a href=\"https://janisoncls.atlassian.net/wiki/download/attachments/494207048/Janison%20Production%20Environment%20portable.exe\">Click to update page</a><br /><br />'

; Reports

$storage_format = $storage_format &	'<table data-layout=\"wide\"><colgroup><col style=\"width:242px;\"/><col style=\"width:109px;\"/><col style=\"width:81px;\"/><col style=\"width:296px;\"/><col style=\"width:232px;\"/></colgroup><tbody><tr><th>Project</th><th>Time</th><th>State</th><th>Global Url</th><th>Queued By</th></tr>' & @CRLF

_Toast_Show(0, $app_name, "Getting deployments", -300, False, True)

Local $deployment = _OctopusGetLatestTenantIdsDeploymentIdTaskIdCreatedForEnvironment("Environments-26")

_Toast_Show(0, $app_name, "Getting deployment states and tenants", -300, False, True)

for $deployment_num = 0 to (UBound($deployment) - 1)

	Local $tenant_id = $deployment[$deployment_num][0]
	Local $deployment_id = $deployment[$deployment_num][1]
	Local $created = $deployment[$deployment_num][2]
	Local $task_id = $deployment[$deployment_num][3]

	Local $deployment_queued_username = _OctopusGetDeploymentQueuedEventUsername($deployment_id)
	Local $tenant_name = _OctopusGetTenantName($tenant_id)
	_OctopusGetTask($task_id)
	Local $decoded_json = Json_Decode($octopus_json)
	Local $state = Json_Get($decoded_json, '.Task.State')
	Local $global_url = ""
	Local $tmp_arr = StringRegExp($octopus_json, '\"Global Url       : (.*)\"', 1)

	if @error = 0 Then

		$global_url = $tmp_arr[0]
	EndIf

	$storage_format = $storage_format & "<tr><td>" & $tenant_name & "</td><td>" & $created & "</td><td>" & $state & "</td><td>" & $global_url & "</td><td>" & $deployment_queued_username & "</td></tr>" & @CRLF
Next

$storage_format = $storage_format &	"</tbody></table>" & @CRLF

; Update Confluence

_Toast_Show(0, $app_name, "Uploading reports to confluence", -300, False, True)
Update_Confluence_Page("https://janisoncls.atlassian.net", "JAST", "495845841", "495747632", "Production Environment", $storage_format)

; Shutdown

_JiraShutdown()
_Toast_Show(0, $app_name, "Done. Refresh the page in Confluence.", -3, False, True)
Sleep(3000)
