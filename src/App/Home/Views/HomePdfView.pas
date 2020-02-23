(*!------------------------------------------------------------
 * [[APP_NAME]] ([[APP_URL]])
 *
 * @link      [[APP_REPOSITORY_URL]]
 * @copyright Copyright (c) [[COPYRIGHT_YEAR]] [[COPYRIGHT_HOLDER]]
 * @license   [[LICENSE_URL]] ([[LICENSE]])
 *------------------------------------------------------------- *)
unit HomePdfView;

interface

{$MODE OBJFPC}
{$H+}

uses

    fano,
    fppdf;

type

    (*!-----------------------------------------------
     * View instance
     *
     * @author [[AUTHOR_NAME]] <[[AUTHOR_EMAIL]]>
     *------------------------------------------------*)
    THomePdfView = class(TInjectableObject, IView)
    private
        function createDocument(const txt : string) : TPDFDocument;
        procedure SimpleText(D: TPDFDocument; APage: integer; const txt : string);
    public

        (*!------------------------------------------------
         * render view
         *------------------------------------------------
         * @param viewParams view parameters
         * @param response response instance
         * @return response
         *-----------------------------------------------*)
        function render(
            const viewParams : IViewParameters;
            const response : IResponse
        ) : IResponse;
    end;

implementation

uses

    Classes,
    SysUtils;

    (*!---------------------------------
     * generate simple text in PDF document
     *----------------------------------
     * @param d pdf document
     * @param apage index of page
     * @param txt text to write
     *-------------------------------------
     * @link https://github.com/graemeg/freepascal/blob/master/packages/fcl-pdf/examples/testfppdf.lpr
     *------------------------------------*)
    procedure THomePdfView.SimpleText(
        D: TPDFDocument;
        APage: integer;
        const txt : string
    );
    var
        P : TPDFPage;
        FtTitle: integer;
        FtWaterMark: integer;
    begin
        P := D.Pages[APage];

        // create the fonts to be used (use one of the 14 Adobe PDF standard fonts)
        FtTitle := D.AddFont('Helvetica');
        FtWaterMark := D.AddFont('Helvetica-Bold');

        { Page title }
        P.SetFont(FtTitle, 23);
        P.SetColor(clBlack, false);
        P.WriteText(25, 20, txt);

        P.SetFont(FtWaterMark, 120);
        P.SetColor(clWaterMark, false);
        P.WriteText(55, 190, txt, 45);

        // -----------------------------------
        // Write text using PDF standard fonts
        P.SetFont(FtTitle, 12);
        P.SetColor(clBlue, false);
        P.WriteText(25, 50, '(25mm,50mm) Helvetica: The quick brown fox jumps over the lazy dog.');
        P.SetColor(clBlack, false);
        P.WriteText(25, 57, 'Click the URL:  https://fanoframework.github.io');
        P.AddExternalLink(54, 58, 49, 5, 'https://fanoframework.github.io', false);

    end;

    (*!---------------------------------
     * create new PDF document
     *----------------------------------
     * @param txt text to write
     * @return pdf document
     *-------------------------------------
     * @link https://github.com/graemeg/freepascal/blob/master/packages/fcl-pdf/examples/testfppdf.lpr
     *------------------------------------*)
    function THomePdfView.createDocument(const txt : string) : TPDFDocument;
    var
        P: TPDFPage;
        S: TPDFSection;
    begin
        Result := TPDFDocument.Create(Nil);
        Result.Infos.Title := txt + ' PDF Demo';
        Result.Infos.Author := txt;
        Result.Infos.Producer := 'Fano Framework';
        Result.Infos.ApplicationName := 'Fano Framework PDF demo';
        Result.Infos.CreationDate := Now;

        Result.StartDocument;
        S := Result.Sections.AddSection; // we always need at least one section
        P := Result.Pages.AddPage;
        P.PaperType := ptA4;
        P.UnitOfMeasure := uomMillimeters;
        S.AddPage(P); // Add the Page to the Section
    end;

    (*!------------------------------------------------
     * render view
     *------------------------------------------------
     * @param viewParams view parameters
     * @param response response instance
     * @return response
     *-----------------------------------------------*)
    function THomePdfView.render(
        const viewParams : IViewParameters;
        const response : IResponse
    ) : IResponse;
    var mem : TStream;
        pdf : TPdfDocument;
        name : string;
    begin
        name := viewParams['name'];
        pdf := createDocument(name);
        try
            simpleText(pdf, 0, name);
            mem := TMemoryStream.create();
            pdf.saveToStream(mem);
            result := TBinaryResponse.create(
                response.headers(),
                'application/pdf',
                //wrap and own stream
                TResponseStream.create(mem)
            );
        finally
            pdf.free();
        end;
    end;

end.
