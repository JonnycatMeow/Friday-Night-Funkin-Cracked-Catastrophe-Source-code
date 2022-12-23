package meta;
#if windows
@:cppFileCode('#include <windows.h>\n#include <dwmapi.h>\n\n#pragma comment(lib, "Dwmapi")')
class WindowsUtil
{
	
	static public function getWindowsTransparent(res:Int = 0)
	{
        @:functionCode('
        HWND hWnd = GetActiveWindow();
        res = SetWindowLongPtrA(hWnd, -20, GetWindowLongPtrA(hWnd, -20) | WS_EX_LAYERED);
        if (res)
        {
            SetLayeredWindowAttributes(hWnd, RGB(2,2,2), 0, LWA_COLORKEY);
        }
        ')

		return res;
	}

	
	static public function getWindowsbackward(res:Int = 0)
	{
        @:functionCode('
        HWND hWnd = GetActiveWindow();
        res = SetWindowLongPtrA(hWnd, -20, GetWindowLongPtrA(hWnd, -20) ^ WS_EX_LAYERED);
        if (res)
        {
            SetLayeredWindowAttributes(hWnd, RGB(2,2,2), 1, LWA_COLORKEY);
        }
        ')
		return res;
	}
}
#end 