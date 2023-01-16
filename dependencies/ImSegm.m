function varargout = ImSegm(varargin)
% IMSEGM M-file for ImSegm.fig
%      IMSEGM, by itself, creates a new IMSEGM or raises the existing
%      singleton*.
%
%      H = IMSEGM returns the handle to a new IMSEGM or the handle to
%      the existing singleton*.
%
%      IMSEGM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMSEGM.M with the given input arguments.
%
%      IMSEGM('Property','Value',...) creates a new IMSEGM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before picrotate3d_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImSegm_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help ImSegm

% Last Modified by GUIDE v2.5 08-Jun-2020 15:39:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImSegm_OpeningFcn, ...
                   'gui_OutputFcn',  @ImSegm_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ImSegm is made visible.
function ImSegm_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImSegm (see VARARGIN)

% Choose default command line output for ImSegm
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ImSegm wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ImSegm_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

global Im
[path,user_cance]=imgetfile();
if user_cance
    msgbox(sprintf('Error'),'Error','Error');
    return
end
Im = imread(path);
Im = im2double(Im); %converts to double

[h, ~] = size(Im);
  
% Set ranges and defaults of sliders
Fudgefactor = 0.8;
set(handles.Fudgefactor_slider,'value',Fudgefactor);                             
set(handles.Fudgefactor_slider,'max',1);                                   
set(handles.Fudgefactor_slider,'min',0);                           
  
SEdil1 = 3;
set(handles.SEdil1_slider,'value',SEdil1);                             
set(handles.SEdil1_slider,'max',20);                                   
set(handles.SEdil1_slider,'min',1);

SEdil2 = 90;
set(handles.SEdil2_slider,'value',SEdil2);                             
set(handles.SEdil2_slider,'max',160);                                   
set(handles.SEdil2_slider,'min',0);

SEsmooth = 1;
set(handles.SEsmooth_slider,'value',SEsmooth);                             
set(handles.SEsmooth_slider,'max',50);                                   
set(handles.SEsmooth_slider,'min',0);

SizeThr = round(h*0.5);
handles.SizeThr = SizeThr;
set(handles.SizeThr_slider,'value',SizeThr);                             
set(handles.SizeThr_slider,'max', h*25);                                   
set(handles.SizeThr_slider,'min',0);

% run image segmentation function
ImSegm = WormSegmentationSobelDetection(Im, Fudgefactor, SEdil1, SEdil2, SEsmooth, SizeThr);

axes(handles.axes1);
% overlay
imshow(labeloverlay(Im,ImSegm))


% --- Executes on slider movement.
function Fudgefactor_slider_Callback(hObject, eventdata, handles)
% hObject    handle to Fudgefactor_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global Im

% run image segmentation function
Fudgefactor = get(handles.Fudgefactor_slider, 'Value');
SEdil1 = get(handles.SEdil1_slider, 'Value');
SEdil2 = get(handles.SEdil2_slider, 'Value');
SEsmooth = get(handles.SEsmooth_slider, 'Value');
SizeThreshold = get(handles.SizeThr_slider, 'Value');

ImSegm = WormSegmentationSobelDetection(Im,Fudgefactor, SEdil1, SEdil2, SEsmooth, SizeThreshold);

axes(handles.axes1);
% overlay
imshow(labeloverlay(Im,ImSegm))

% --- Executes during object creation, after setting all properties.
function Fudgefactor_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Fudgefactor_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in reset_pushbutton.
function reset_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to reset_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Im

Fudgefactor = 0.8;
SEdil1 = 3;
SEdil2 = 90;
SEsmooth = 1;
[h, ~] = size(Im);
SizeThr = round(h*0.2);
% Set ranges and defaults of sliders
set(handles.Fudgefactor_slider,'value',Fudgefactor);                                                   
set(handles.SEdil1_slider,'value',SEdil1);                             
set(handles.SEdil2_slider,'value',SEdil2);                             
set(handles.SEsmooth_slider,'value',SEsmooth); 
set(handles.SizeThr_slider,'value', SizeThr);                             


% Choose default command line output for ImSegm
handles.output = hObject;
% run image segmentation function
ImSegm = WormSegmentationSobelDetection(Im, Fudgefactor, SEdil1, SEdil2, SEsmooth, SizeThr);

axes(handles.axes1);
% overlay
imshow(labeloverlay(Im,ImSegm))     

% --- Executes on button press in segmOK_pushbutton.
function segmOK_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to segmOK_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Fudgefactor = get(handles.Fudgefactor_slider, 'Value');
SEdil1 = get(handles.SEdil1_slider, 'Value');
SEdil2 = round(get(handles.SEdil2_slider, 'Value'));
SEsmooth = get(handles.SEsmooth_slider, 'Value');
SizeThr = round(get(handles.SizeThr_slider, 'Value'));


assignin('base','Fudgefactor',Fudgefactor)
assignin('base','SEdil1',SEdil1)
assignin('base','SEdil2',SEdil2)
assignin('base','SEsmooth',SEsmooth)
assignin('base','SizeThr',SizeThr)
close all

% --- Executes on slider movement.
function SEdil1_slider_Callback(hObject, eventdata, handles)
% hObject    handle to SEdil1_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Im

% run image segmentation function
Fudgefactor = get(handles.Fudgefactor_slider, 'Value');
SEdil1 = round(get(handles.SEdil1_slider, 'Value'));
SEdil2 = get(handles.SEdil2_slider, 'Value');
SEsmooth = get(handles.SEsmooth_slider, 'Value');
SizeThreshold = get(handles.SizeThr_slider, 'Value');

ImSegm = WormSegmentationSobelDetection(Im,Fudgefactor, SEdil1, SEdil2, SEsmooth, SizeThreshold);

axes(handles.axes1);
% overlay
imshow(labeloverlay(Im,ImSegm))


% --- Executes during object creation, after setting all properties.
function SEdil1_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SEdil1_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function SEdil2_slider_Callback(hObject, eventdata, handles)
% hObject    handle to SEdil2_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Im

% run image segmentation function
Fudgefactor = get(handles.Fudgefactor_slider, 'Value');
SEdil1 = get(handles.SEdil1_slider, 'Value');
SEdil2 = round(get(handles.SEdil2_slider, 'Value'));
SEsmooth = get(handles.SEsmooth_slider, 'Value');
SizeThreshold = get(handles.SizeThr_slider, 'Value');

ImSegm = WormSegmentationSobelDetection(Im,Fudgefactor, SEdil1, SEdil2, SEsmooth, SizeThreshold);

axes(handles.axes1);
% overlay
imshow(labeloverlay(Im,ImSegm))



% --- Executes during object creation, after setting all properties.
function SEdil2_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SEdil2_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function SEsmooth_slider_Callback(hObject, eventdata, handles)
% hObject    handle to SEsmooth_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Im

% run image segmentation function
Fudgefactor = get(handles.Fudgefactor_slider, 'Value');
SEdil1 = get(handles.SEdil1_slider, 'Value');
SEdil2 = get(handles.SEdil2_slider, 'Value');
SEsmooth = round(get(handles.SEsmooth_slider, 'Value'));
SizeThreshold = get(handles.SizeThr_slider, 'Value');

ImSegm = WormSegmentationSobelDetection(Im,Fudgefactor, SEdil1, SEdil2, SEsmooth, SizeThreshold);

axes(handles.axes1);
% overlay
imshow(labeloverlay(Im,ImSegm))


% --- Executes during object creation, after setting all properties.
function SEsmooth_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SEsmooth_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function SizeThr_slider_Callback(hObject, eventdata, handles)
% hObject    handle to SizeThr_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Im

% run image segmentation function
Fudgefactor = get(handles.Fudgefactor_slider, 'Value');
SEdil1 = get(handles.SEdil1_slider, 'Value');
SEdil2 = get(handles.SEdil2_slider, 'Value');
SEsmooth = get(handles.SEsmooth_slider, 'Value');
SizeThreshold = round(get(handles.SizeThr_slider, 'Value'));

ImSegm = WormSegmentationSobelDetection(Im,Fudgefactor, SEdil1, SEdil2, SEsmooth, SizeThreshold);

axes(handles.axes1);
% overlay
imshow(labeloverlay(Im,ImSegm))


% --- Executes during object creation, after setting all properties.
function SizeThr_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SizeThr_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
