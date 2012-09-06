#include "stdafx.h"
#include "iFileSilent.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

// CiFileSilentApp construction
CiFileSilentApp::CiFileSilentApp() {}

// The one and only CiFileSilentApp object
CiFileSilentApp theApp;

// Turns all slashes into Windows slashes
inline void FlipSlashes(TCHAR *szLink)
{
	for (unsigned i=0; i < _tcslen(szLink); i++)
		if (szLink[i] == '/') szLink[i] = '\\';
}

// This assumes szTarget is always large enough to contain szSource plus any substitutions
inline void URLDecode(TCHAR *szTarget, const TCHAR *szSource, unsigned uLenSource)
{
	unsigned i, j;
	for (i=0, j=0; i < uLenSource;)
	{
		if (szSource[i] == '%')
		{
			// Found at least something following the quote
			if (szSource[i + 1] != '\0')
			{
				// Found a potentially valid escape sequence
				if (szSource[i + 2] != '\0')
				{
					TCHAR c1 = szSource[i + 1], c2 = szSource[i + 2];

					if (isxdigit(c1) && isxdigit(c2))
					{
						c1 = (TCHAR)tolower(c1);
						c2 = (TCHAR)tolower(c2);

						if( c1 <= '9' )
							c1 = c1 - '0';
						else
							c1 = c1 - 'a' + 10;
						if( c2 <= '9' )
							c2 = c2 - '0';
						else
							c2 = c2 - 'a' + 10;

						szTarget[j++] = ( 16 * c1 + c2 );
						i+=3;
					}
				}
				// Special case for escaped quote
				else if (szSource[i + 1] == '%')
				{
					szTarget[j++] = '%';
					i+=2;
				}
			}
		}
		// Special handling for plus in addition to %20
		else if (szSource[i] == '+')
		{
			szTarget[j++] = ' ';
			i++;
		}
		else
		{
			szTarget[j++] = szSource[i++];
		}
	}
	szTarget[j] = '\0';
}

// CiFileSilentApp initialization
BOOL CiFileSilentApp::InitInstance()
{
	STARTUPINFO si;
	PROCESS_INFORMATION pi;
	TCHAR szProcess[MAX_PATH] = {0};
	TCHAR *szLink;
	LPWSTR *argv;
	int argc;

	CWinApp::InitInstance();

	ZeroMemory( &si, sizeof(si) );
    si.cb = sizeof(si);
    ZeroMemory( &pi, sizeof(pi) );

	argv = CommandLineToArgvW(GetCommandLineW(), &argc);
	// We should be called as a URI handler with 2 arguments.  If not, just quit.
#ifdef DEBUG
	wsprintf(szProcess, _T("Arguments: %d"), argc);
	MessageBox(NULL, szProcess, L"TEXT", MB_OK);
#endif
	if (!argv || argc != 2 || _tcsncmp(argv[1], L"ifile:", 6))
		return FALSE;

	szLink = argv[1] + 6 /* ifile: */;
	FlipSlashes(szLink);

	// Quote the process to protect against abuse and eliminate a single trailing slash, if present.
	_tcscpy_s(szProcess, MAX_PATH, L"\"");
	URLDecode(szProcess + _tcslen(szProcess), szLink, _tcslen(szLink));
	if (szProcess[_tcslen(szProcess) - 1] == '\\' || szProcess[_tcslen(szProcess) - 1] == '"')
		szProcess[_tcslen(szProcess) - 1] = '\0';
	_tcscat_s(szProcess, MAX_PATH, L"\"");

#ifdef DEBUG
	MessageBox(NULL, szProcess, L"TEXT", MB_OK);
#endif
	
	CoInitializeEx(NULL, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
	(void)ShellExecute(NULL, NULL, szProcess, NULL, NULL, SW_SHOWNORMAL);

	// Since the dialog has been closed, return FALSE so that we exit the
	//  application, rather than start the application's message pump.
 	return FALSE;
}