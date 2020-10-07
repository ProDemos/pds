<?php

$cwd = getcwd();
chdir(__DIR__);
require_once('../vendor/autoload.php');

$paths = [
    'views'     => '../resources/twig',
    'pages'     => '../pages',
    'config'    => '../config',
    'assets'    => '../../../assets',
    'output'    => '../../html'
];



$loader = new \Twig\Loader\FilesystemLoader([
    $paths['views'], $paths['pages'], $paths['assets'].'/twig'
]);

$twig = new \Twig\Environment($loader);
$twig->addExtension(new Twig\Extra\Html\HtmlExtension());


// read lots of yaml
$yaml = new Symfony\Component\Yaml\Parser();

// core config
$data = $yaml->parse(file_get_contents($paths['config'].'/styleguide.yml'));

// menu
$nav = $yaml->parse(file_get_contents($paths['config'].'/navigation.yml'));
$data['navigation'] = $nav;

// defined widgets
foreach(scandir($paths['assets'].'/twig') as $dirname) {
    $xmpfile = $paths['assets'].'/twig/'.$dirname.'/_styleguide.yml';
    if (file_exists($xmpfile)) {
        $xmpdata = $yaml->parse(file_get_contents($xmpfile));
        $data['components'][$dirname] = $xmpdata;
    }
}

// generate list of icons
$data['icons'] = array();
$iconrit = new RecursiveDirectoryIterator($paths['assets'].'/images/icons');
$iconritit = new RecursiveIteratorIterator($iconrit);
foreach ($iconritit as $path) {
    if (!is_dir($path)) {
        $icon = str_replace($paths['assets'].'/images/icons/','',$path);
        $data['icons'][] = $icon;
    }
}
sort($data['icons']);

// now render all pages defined in 'pages' to html
// the pages define which widgets it will display (if any)
// using the _styleguide.yml defintions in the assets/twig folder
renderTemplates($paths['pages'],$paths['output']);

chdir($cwd);

function renderTemplates($sourcedir,$outputdir,$subdir='',$root='') {
    global $twig, $data;
    
    foreach(scandir($sourcedir.'/'.$subdir) as $filename) {

        $filepath = $sourcedir.'/'.$subdir.'/'.$filename;
  
        if (!is_dir($filepath)) {
            if (preg_match('/twig$/', $filename)) {
                
                $outputname = preg_replace('/.twig$/','', $filename);
                $outputlink = $subdir.$outputname;
                $outputpath = $outputdir.'/'.$outputlink;

                // pass some data to twig and render
                $data['rooturi']=$root;
                foreach ($data['navigation'] as &$topitem) {
                    $topitem['current']=($topitem['uri']==$outputlink);
                    $topitem['intrail']=false;
                    foreach ($topitem['items'] as &$subitem) {
                        $subitem['current']=($subitem['uri']==$outputlink);
                        if ($subitem['current']) $topitem['intrail']=true;
                    }
                }
                unset($topitem);
                unset($subitem);
                $html = $twig->render($subdir.'/'.$filename, $data);

                $parentdir = dirname($outputpath);
                if (!is_dir($parentdir)) {
                    echo "Creating dir .. ".$parentdir.PHP_EOL;
                    if (!mkdir($parentdir, 0777, true)) {
                        die('Failed to create directory '.$parentdir);
                    }
                }
                
                echo "Writing file .. ".$outputpath.PHP_EOL;
                file_put_contents($outputpath,$html);

               
            }
        } else {
            if (substr($filename,0,1)!='.' && substr($filename,0,1)!='_') {
                renderTemplates($sourcedir,$outputdir,$subdir.$filename.'/','../'.$root);
            }
        }
    }
}
