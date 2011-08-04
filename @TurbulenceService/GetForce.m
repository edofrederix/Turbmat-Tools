function GetForceResult = GetForce(obj,authToken,dataset,time,spatialInterpolation,temporalInterpolation,points)
%GetForce(obj,authToken,dataset,time,spatialInterpolation,temporalInterpolation,points)
%
%   Retrieve the force for a number of points for a given time.
%   
%     Input:
%       authToken = (string)
%       dataset = (string)
%       time = (float)
%       spatialInterpolation = (SpatialInterpolation)
%       temporalInterpolation = (TemporalInterpolation)
%       points = (ArrayOfPoint3)
%   
%     Output:
%       GetForceResult = (ArrayOfVector3)

% Build up the argument lists.
values = { ...
   authToken, ...
   dataset, ...
   time, ...
   spatialInterpolation, ...
   temporalInterpolation, ...
   points, ...
   };
names = { ...
   'authToken', ...
   'dataset', ...
   'time', ...
   'spatialInterpolation', ...
   'temporalInterpolation', ...
   'points', ...
   };
types = { ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}float', ...
   '{http://turbulence.pha.jhu.edu/}SpatialInterpolation', ...
   '{http://turbulence.pha.jhu.edu/}TemporalInterpolation', ...
   '{http://turbulence.pha.jhu.edu/}ArrayOfPoint3', ...
   };

% Create the message, make the call, and convert the response into a variable.
soapMessage = turbm_createSoapMessage( ...
    'http://turbulence.pha.jhu.edu/', ...
    'GetForce', ...
    values,names,types,'document');
response = turbm_callSoapService( ...
    obj.endpoint, ...
    'http://turbulence.pha.jhu.edu/GetForce', ...
    soapMessage);
GetForceResult = turbm_parseSoapResponse(response);
