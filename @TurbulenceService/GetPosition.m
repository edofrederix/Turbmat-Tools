function GetPositionResult = GetPosition(obj,authToken,dataset,StartTime,dt,nt,spatialInterpolation,points)
%GetPosition(obj,authToken,dataset,StartTime,dt,nt,spatialInterpolation,points)
%
%   [UNDER DEVELOPMENT] FluidParticleTracking
%   
%     Input:
%       authToken = (string)
%       dataset = (string)
%       StartTime = (float)
%       dt = (float)
%       nt = (int)
%       spatialInterpolation = (SpatialInterpolation)
%       points = (ArrayOfPoint3)
%   
%     Output:
%       GetPositionResult = (ArrayOfPoint3)

% Build up the argument lists.
values = { ...
   authToken, ...
   dataset, ...
   StartTime, ...
   dt, ...
   nt, ...
   spatialInterpolation, ...
   points, ...
   };
names = { ...
   'authToken', ...
   'dataset', ...
   'StartTime', ...
   'dt', ...
   'nt', ...
   'spatialInterpolation', ...
   'points', ...
   };
types = { ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}float', ...
   '{http://www.w3.org/2001/XMLSchema}float', ...
   '{http://www.w3.org/2001/XMLSchema}int', ...
   '{http://turbulence.pha.jhu.edu/}SpatialInterpolation', ...
   '{http://turbulence.pha.jhu.edu/}ArrayOfPoint3', ...
   };

% Create the message, make the call, and convert the response into a variable.
soapMessage = turbm_createSoapMessage( ...
    'http://turbulence.pha.jhu.edu/', ...
    'GetPosition', ...
    values,names,types,'document');
response = turbm_callSoapService( ...
    obj.endpoint, ...
    'http://turbulence.pha.jhu.edu/GetPosition', ...
    soapMessage);
GetPositionResult = turbm_parseSoapResponse(response);
