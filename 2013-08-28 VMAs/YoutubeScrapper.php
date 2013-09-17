<? php 

$videos = array("http://www.youtube.com/watch?v=uuZE_IRwLNI",
				"http://www.youtube.com/watch?v=QK8mJJJvaes",
				"http://www.youtube.com/watch?v=e-fA-gBCkj0",
				"http://www.youtube.com/watch?v=yyDUC1LUXSU",
				"http://www.youtube.com/watch?v=vNoKguSdy4Y",
				"http://www.youtube.com/watch?v=o_v9MY_FMcw",
				"http://www.youtube.com/watch?v=LrUvu1mlWco",
				"http://www.youtube.com/watch?v=n-D1EB74Ckg",
				"http://www.youtube.com/watch?v=AtKZKl7Bgu0",
				"http://www.youtube.com/watch?v=5NV6Rdv1a3I",
				"http://www.youtube.com/watch?v=2zNSgSzhBfM",
				"http://www.youtube.com/watch?v=RubBzkZzpUA",
				"http://www.youtube.com/watch?v=8-ejyHzz3XE",
				"http://www.youtube.com/watch?v=liZm1im2erU",
				"http://www.youtube.com/watch?v=7AjD7nKiUQ4",
				"http://www.youtube.com/watch?v=c4BLVznuWnU",
				"http://www.youtube.com/watch?v=JF8BRvqGCNs",
				"http://www.youtube.com/watch?v=OpQFFLBMEPI",
				"http://www.youtube.com/watch?v=AByfaYcOm4A",
				"http://www.youtube.com/watch?v=q7yCLn-O-Y0",
				"http://www.youtube.com/watch?v=IsUsVbTj2AY",
				"http://www.youtube.com/watch?v=5jlI4uzZGjU",
				"http://www.youtube.com/watch?v=AtKZKl7Bgu0",
				"http://www.youtube.com/watch?v=yWbMz_aBlMU",
				"http://www.youtube.com/watch?v=hlVBg7_08n0",
				"http://www.youtube.com/watch?v=jqo9gPxT6A8",
				"http://www.youtube.com/watch?v=mTrnI-XKEH0",
				"http://www.youtube.com/watch?v=i41qWJ6QjPI",
				"http://www.youtube.com/watch?v=ktvTqknDobU",
				"http://www.youtube.com/watch?v=LkIWmsP3c_s",
				"http://www.youtube.com/watch?v=rGKfrgqWcv0",
				"http://www.youtube.com/watch?v=sxDdEPED0h8",
				"http://www.youtube.com/watch?v=Qg6BwvDcANg",
				"http://www.youtube.com/watch?v=tEddixS-UoU",
				"http://www.youtube.com/watch?v=47dtFZ8CFo8",
				"http://www.youtube.com/watch?v=y9uSyICrtow",
				"http://www.youtube.com/watch?v=mX46e4GtlXM",
				"http://www.youtube.com/watch?v=nPvuNsRccVw",
				"http://www.youtube.com/watch?v=DGIgXP9SvB8",
				"http://www.youtube.com/watch?v=BofL1AaiTjo",
				"http://www.youtube.com/watch?v=B9rSBcoX9ak",
				"http://www.youtube.com/watch?v=iGs1gODLiSQ",
				"http://www.youtube.com/watch?v=Py_-3di1yx0",
				"http://www.youtube.com/watch?v=jmRI3Ew4BvA",
				"http://www.youtube.com/watch?v=_GbYR5Aud4Y",
				"http://www.youtube.com/watch?v=BUULBlDcju4",
				"http://www.youtube.com/watch?v=RubBzkZzpUA",
				"http://www.youtube.com/watch?v=17ozSeGw-fY",
				"http://www.youtube.com/watch?v=QhhnUTNror8",
				"http://www.youtube.com/watch?v=TRNGpATRCrI",
				"http://www.youtube.com/watch?v=ktBMxkLUIwY",
				"http://www.youtube.com/watch?v=IxxstCcJlsc",
				"http://www.youtube.com/watch?v=2PEG82Udb90",
				"http://www.youtube.com/watch?v=O1OTWCd40bc",
				"http://www.youtube.com/watch?v=_zR6ROjoOX0"
				
				);
				
$n = count($videos);
$output = array("title","date","views","ratings","avg_score");

for ($i = 0; $i < $n; $i++){

	$urls = $videos[$i];
	preg_match("/=(.*)/",$urls,$matches);
	$video_ID = $matches[1];
	$JSON = file_get_contents("https://gdata.youtube.com/feeds/api/videos/{$video_ID}?v=2&alt=json");
	$JSON_Data = json_decode($JSON);
	$title = $JSON_Data->{'entry'}->{'title'}->{'$t'};
	$views = $JSON_Data->{'entry'}->{'yt$statistics'}->{'viewCount'};
	$length = $JSON_Data->{'entry'}->{'media$group'}->{'yt$duration'}->{'seconds'};
	$upload = substr($JSON_Data->{'entry'}->{'published'}->{'$t'},0,10);
	$score = $JSON_Data->{'entry'}->{'gd$rating'}->{'average'};
 	$ratings = $JSON_Data->{'entry'}->{'gd$rating'}->{'numRaters'};
	$likes = $JSON_Data->{'entry'}->{'yt$rating'}->{'numLikes'};
	$dislikes = $JSON_Data->{'entry'}->{'yt$rating'}->{'numDislikes'};
	
	$metrics = array($title,$upload,$length,$views,$ratings,$score,$likes,$dislikes);
	array_push($output,$metrics);
} 

print_r($output);

$fp = fopen('mtvFullList.csv', 'w');

foreach ($output as $fields) {
    fputcsv($fp, $fields);
}

fclose($fp);

?>