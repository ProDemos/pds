<?php

namespace ProDemos\PDS;

use Composer\Factory;
use Composer\Script\Event;
use Composer\Installer\PackageEvent;

use Symfony\Component\Yaml\Parser;

use Twig\Loader\FilesystemLoader;
use Twig\Environment;
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
        
        $this->twig = new Environment($loader);
        $this->twig->addExtension(new HtmlExtension());
        
        
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