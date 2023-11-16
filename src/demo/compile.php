<?php

require_once __DIR__ . '/../../vendor/autoload.php';

use Symfony\Component\Yaml\Parser;

use Twig\Loader\FilesystemLoader;
use Twig\Environment;
use Twig\TwigFilter;
use Twig\Extra\Html\HtmlExtension;

class TwigCompiler
{
    private $srcdir;
    private $dstdir;
    private $twig;
    private $data;

    private $paths = [
        'views'     => 'twig',
        'pages'     => 'pages',
        'config'    => 'config',
        'assets'    => '../assets'
    ];

    public function __construct($srcdir,$dstdir) {
        $this->srcdir = $srcdir;
        $this->dstdir = $dstdir;
    }

    public function compile()
    {
        $cwd = getcwd();
        chdir($this->srcdir);

        $loader = new FilesystemLoader([
            $this->paths['views'], 
            $this->paths['pages'], 
            $this->paths['assets'].'/twig'
        ]);
        
        

        // read lots of yaml
        $yaml = new Parser();
        
        // core config
        $this->data = $yaml->parse(file_get_contents($this->paths['config'].'/config.yml'));
        
        // menu
        $nav = $yaml->parse(file_get_contents($this->paths['config'].'/navigation.yml'));
        $this->data['navigation'] = $nav;
        
        // defined components
        foreach(glob($this->paths['config'].'/components/*.yml') as $xmpfile) {
            $xmpdata = $yaml->parse(file_get_contents($xmpfile));
            $this->data['components'][basename($xmpfile,'.yml')] = $xmpdata;
        }
        
        // generate list of images except icons and favicons
        $this->data['images'] = array();
        $imgrit = new \RecursiveDirectoryIterator($this->paths['assets'].'/images');
        $imgritit = new \RecursiveIteratorIterator($imgrit);
        foreach ($imgritit as $path) {
            if (!is_dir($path) 
                && strpos($path,'/icons/') == false 
                && strpos($path,'/favicons/') ===false
                && strpos($path,'/.') ===false) {
                $image = str_replace($this->paths['assets'].'/images/','',$path);
                if (strpos($image,'.')!==0) $this->data['images'][] = $image;
            }
        }
        sort($this->data['images']);

        // generate list of icons
        $this->data['icons'] = array();
        $iconrit = new \RecursiveDirectoryIterator($this->paths['assets'].'/images/icons');
        $iconritit = new \RecursiveIteratorIterator($iconrit);
        foreach ($iconritit as $path) {
            if (!is_dir($path)) {
                $icon = str_replace($this->paths['assets'].'/images/icons/','',$path);
                if (strpos($icon,'.')!==0) $this->data['icons'][] = $icon;
            }
        }
        sort($this->data['icons']);
        
        // create a twigparser
        $this->twig = new Environment($loader);

        // load some extensions
        $this->twig->addExtension(new HtmlExtension());
        
        // an anonymous function
        $this->twig->addFilter(new TwigFilter('basename', function ($path) {
            return pathinfo($path, PATHINFO_FILENAME);
        }));

        $this->twig->addFilter(new TwigFilter('tidy', function ($html) {
            $html = preg_replace('/\s+/',' ',$html);
            $dom = new \DOMDocument();
            $dom->preserveWhiteSpace = false;
            $dom->formatOutput = true;
            try {
                //libxml_use_internal_errors(true);
                $dom->loadHTML($html,LIBXML_HTML_NOIMPLIED | LIBXML_NOERROR | LIBXML_ERR_NONE |  LIBXML_NOWARNING );
                $tidy = $dom->saveXML($dom->documentElement,LIBXML_NOEMPTYTAG);
                // play it again sam
                $dom->loadXML($tidy);
                $tidy = $dom->saveXML($dom->documentElement,LIBXML_NOEMPTYTAG);
                $html = $tidy;
            } catch (ErrorException $x) {
                // oops
            }
            return $html;
        }));

        // now render all pages defined in 'pages' to html
        // the pages define which widgets it will display (if any)
        // using the _styleguide.yml defintions in the assets/twig folder

        chdir($cwd);
        $this->renderTemplates($this->srcdir.'/'.$this->paths['pages'],$this->dstdir);
       
        

        
    }

    public function renderTemplates($sourcedir,$outputdir,$subdir='',$root='') {
        
        foreach(scandir($sourcedir.'/'.$subdir) as $filename) {
    
            $filepath = $sourcedir.'/'.$subdir.'/'.$filename;
      
            if (!is_dir($filepath)) {
                if (preg_match('/twig$/', $filename)) {
                    
                    $outputname = preg_replace('/.twig$/','', $filename);
                    $outputlink = $subdir.$outputname;
                    $outputpath = $outputdir.'/'.$outputlink;
    
                    // pass some data to twig and render
                    $this->data['rooturi']=$root;
                    foreach ($this->data['navigation'] as &$topitem) {
                        $topitem['current']=($topitem['uri']==$outputlink);
                        $topitem['intrail']=false;
                        foreach ($topitem['items'] as &$subitem) {
                            $subitem['current']=($subitem['uri']==$outputlink);
                            if ($subitem['current']) $topitem['intrail']=true;
                        }
                    }
                    unset($topitem);
                    unset($subitem);
                    $html = $this->twig->render($subdir.'/'.$filename, $this->data);
    
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
                    $this->renderTemplates($sourcedir,$outputdir,$subdir.$filename.'/','../'.$root);
                }
            }
        }
    }

}

$srcdir = $argv[1];
$dstdir = $argv[2];
if (!$srcdir || !$dstdir) {
    echo "Usage: compile $srcdir $dstdir";
    exit(1);
}
$compiler = new TwigCompiler($srcdir,$dstdir);
$compiler->compile();