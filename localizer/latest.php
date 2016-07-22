<?php 

if (file_exists('appcast.xml')) {
	$xml = simplexml_load_file('appcast.xml');
	$items = $xml->channel[0]->item;
	$file = dirname($_SERVER['SCRIPT_FILENAME'])."/".basename((string)$items[0]->enclosure->attributes()->url);
	if (is_file($file) and (substr($file, strrpos($file, '.')) == ".zip")) {
		header("Pragma: public");
		header("Expires: 0");
		header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
		header("Cache-Control: private", false);
		header("Content-Type: application/zip" );
		header("Content-Disposition: attachment; filename=\"".basename($file)."\";");
		header("Content-Transfer-Encoding:  binary");
		header("Content-Length: ".filesize($file));
		readfile($file);
		// -- Piwik Tracking API init -- 
		require_once "PiwikTracker.php";
		PiwikTracker::$URL = 'https://statistik.glyphsapp.com/';
		$piwikTracker = new PiwikTracker( $idSite = 2 );
		// Sends Tracker request via http
		$piwikTracker->doTrackPageView($file);
		exit;
	}
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
	<title><?php echo "File not found!"; ?></title>
</head>

<body>
<?php echo "File ".basename($file)." not found!"; ?>
</body>
</html>
