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
        function createDocument() : TPDFDocument;
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
        P.WriteText(55, 190, 'Sample', 45);

        // -----------------------------------
        // Write text using PDF standard fonts
        P.SetFont(FtTitle, 12);
        P.SetColor(clBlue, false);
        P.WriteText(25, 50, '(25mm,50mm) Helvetica: The quick brown fox jumps over the lazy dog.');
        P.SetColor(clBlack, false);
        P.WriteText(25, 57, 'Click the URL:  https://fanoframework.github.io');
        P.AddExternalLink(54, 58, 49, 5, 'https://fanoframework.github.io', false);

    end;

    function THomePdfView.createDocument() : TPDFDocument;
    var
        P: TPDFPage;
        S: TPDFSection;
        i: integer;
        lPageCount: integer;
    begin
        Result := TPDFDocument.Create(Nil);
        Result.Infos.Title := 'Fano PDF Demo';
        Result.Infos.Author := 'Graeme Geldenhuys';
        Result.Infos.Producer := 'fpGUI Toolkit 1.4.1';
        Result.Infos.ApplicationName := 'Fano Framework';
        Result.Infos.CreationDate := Now;

        Result.StartDocument;
        S := Result.Sections.AddSection; // we always need at least one section
        lPageCount := 1;
        for i := 1 to lPageCount do
        begin
            P := Result.Pages.AddPage;
            P.PaperType := ptA4;
            P.UnitOfMeasure := uomMillimeters;
            S.AddPage(P); // Add the Page to the Section
        end;
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
    begin
        pdf := createDocument();
        try
            simpleText(pdf, 0, viewParams['name']);
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
