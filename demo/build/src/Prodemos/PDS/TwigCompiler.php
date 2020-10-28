<?php

namespace ProDemos\PDS;

use Composer\Factory;
use Composer\Script\Event;
use Composer\Installer\PackageEvent;

use Symfony\Component\Yaml\Parser;

use Twig\Loader\FilesystemLoader;
use Twig\Environment;
use Twig\TwigFilter;
use Twig\Extra\Html\HtmlExtension;

class TwigCompiler
{
    private $twig;
    private $data;

    private $paths = [
        'views'     => 'resources/twig',
        'pages'     => 'pages',
        'config'    => 'config',
        'assets'    => '../../assets',
        'output'    => '../html'
    ];

	public static function run(Event $event)
    {

        $composer = $event->getComposer();
        $rootdir = dirname(Factory::getComposerFile());

        $compiler = new TwigCompiler();
        $compiler->compile($rootdir);

        echo "compiled!".PHP_EOL;
        
    }

    public function compile($rootdir)
    {
        $cwd = getcwd();
        chdir($rootdir);

        $loader = new FilesystemLoader([
            $this->paths['views'], 
            $this->paths['pages'], 
            $this->paths['assets'].'/twig'
        ]);
        
        

        // read lots of yaml
        $yaml = new Parser();
        
        // core config
        $this->data = $yaml->parse(file_get_contents($this->paths['config'].'/styleguide.yml'));
        
        // menu
        $nav = $yaml->parse(file_get_contents($this->paths['config'].'/navigation.yml'));
        $this->data['navigation'] = $nav;
        
        // defined widgets
        foreach(scandir($this->paths['assets'].'/twig') as $dirname) {
            $xmpfile = $this->paths['assets'].'/twig/'.$dirname.'/_styleguide.yml';
            if (file_exists($xmpfile)) {
                $xmpdata = $yaml->parse(file_get_contents($xmpfile));
                $this->data['components'][$dirname] = $xmpdata;
            }
        }
        
        // generate list of images except icons
        $this->data['images'] = array();
        $imgrit = new \RecursiveDirectoryIterator($this->paths['assets'].'/images');
        $imgritit = new \RecursiveIteratorIterator($imgrit);
        foreach ($imgritit as $path) {
            if (!is_dir($path) && strpos($path,'/icons/')===false) {
                $image = str_replace($this->paths['assets'].'/images/','',$path);
                $this->data['images'][] = $image;
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
                $this->data['icons'][] = $icon;
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
                $tidy = $dom->saveXML($dom->documentElement);
                // play it again sam
                $dom->loadXML($tidy);
                $tidy = $dom->saveXML($dom->documentElement);
                $html = $tidy;
            } catch (ErrorException $x) {
                // oops
            }
            return $html;
        }));

        // now render all pages defined in 'pages' to html
        // the pages define which widgets it will display (if any)
        // using the _styleguide.yml defintions in the assets/twig folder

        $this->renderTemplates($this->paths['pages'],$this->paths['output']);
       
        chdir($cwd);

        
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