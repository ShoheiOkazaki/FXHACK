---
title: "[Deadline] KarmaをDeadlineに投げてみよう （意識低い系）"
date: 2022-09-02T12:27:07+09:00
tags: ["Houdini", "Python", "Workflow", "Deadline"]
draft: true
---

## DEMOREEL
まずは
job_info plugin_info



``` python
def SubmitRenderJob( node, jobProperties, dependencies ):
```
``` py
# -------------------------------------------------------------------EDIT START------------------------------------------------------------------------------------------------------
CUSTOM_NODE_DICT = {
    # -- Node Label Name : Deadline pulgin name
    "Command Line (Deadline)": "CommandLine",
    "nm Deadline FFmpeg": "FFmpeg"
    }

def valueTrueFalse(node,parm):
    result = "False"
    if node.parm(parm):
        if node.parm(parm).eval():
            result = "True"
    return result
# -------------------------------------------------------------------EDIT END  ------------------------------------------------------------------------------------------------------
```


```python
    subInfo = json.loads( hou.getenv("Deadline_Submission_Info") )
    homeDir = subInfo["UserHomeDir"]

    # -------------------------------------------------------------------EDIT START------------------------------------------------------------------------------------------------------
    if node.type().description() in list(CUSTOM_NODE_DICT.keys()):
        exportJob = True
    # -------------------------------------------------------------------EDIT END  -------------------------------------------------------------------------------------------------------

    renderJobIds = []
    exportJobIds = []
    assemblyJobIds = []


    if exportJob:
        exportType = node.type().description()        

        # rename the export type to RenderMan so the RenderMan Deadline plugin is used
        if exportType == "RenderMan RIS":
            exportType = "RenderMan"

        if exportType == "RenderMan":
            ifdFile = get_renderman_standalone_export_path(node)
        else:
            #get ifdfile path for export
            ifdFile, paddedIfdFile = get_standalone_export_path(node)

        if ifdFile == "":
            exportJob = False

        # -------------------------------------------------------------------EDIT START------------------------------------------------------------------------------------------------------
        if exportType in list(CUSTOM_NODE_DICT.keys()):
            exportType = CUSTOM_NODE_DICT[exportType]
            exportJob = True
            regionJobCount = 0
        # -------------------------------------------------------------------EDIT END  -------------------------------------------------------------------------------------------------------


    #get the output file path
    output, outputFile, paddedOutputFile = get_render_output_filepath(node)
```


Dependencyをくみます

``` python
        if exportJob:
            exportTilesEnabled = tilesEnabled
            exportJobCount = 1

            if is_vray_renderer_node( node ):
                exportType = "Vray"

            lowerExportType = exportType.lower()
            if exportTilesEnabled:
                if ( exportType == "Mantra" and node.parm("vm_tile_render") is not None ) or exportType == "Arnold":
                    if not singleFrameTiles:
                        if jigsawEnabled:
                            exportJobCount = jigsawRegionCount
                        else:
                            exportJobCount = tilesInX * tilesInY
                else:
                    exportTilesEnabled = False
            exportJobDependencies = ",".join( renderJobIds )

            # -------------------------------------------------------------------EDIT START------------------------------------------------------------------------------------------------------
            if exportType in list(CUSTOM_NODE_DICT.values()):
                print("DEBUG:dependencies", dependencies)
                exportJobDependencies = dependencies
            # -------------------------------------------------------------------EDIT END  -------------------------------------------------------------------------------------------------------

            for exportJobNum in range( 0, exportJobCount ):
```


ノードのパラメータを読み取りましょう

``` python
                    elif exportType == "Vray":
                        exportFileName = ifdFile
                        if export_will_overwrite( node, jobProperties ):
                            exportFileName = hou.expandString(".$F4").join(os.path.splitext(ifdFile))
                        fileHandle.write( "InputFilename=%s\n" % exportFileName )
                        fileHandle.write( "CommandLineOptions=%s\n" % jobProperties.get( "vrayarguments", "" ) )
                        fileHandle.write( "Threads=%s\n" % jobProperties.get( "vraythreads", 0 ) )

                        # Check whether the .vrscene file names are different
                        SeparateFilesPerFrame = ( not single_export_file( node ) ) or export_will_overwrite( node, jobProperties )
                        fileHandle.write( "SeparateFilesPerFrame=%s\n" % SeparateFilesPerFrame )

                    # -------------------------------------------------------------------EDIT START------------------------------------------------------------------------------------------------------
                    elif exportType == "CommandLine":
                        fileHandle.write( "Executable=%s\n" % node.parm("dl_commandline_executable").evalAsString() )
                        fileHandle.write( "Arguments=%s\n" % node.parm("dl_commandline_arguments").evalAsString() )
                    # -------------------------------------------------------------------EDIT END  -------------------------------------------------------------------------------------------------------
```