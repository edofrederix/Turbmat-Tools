%
% JHU Turbulence Database Matlab client code
%   
% Create SOAP Message, part of Turbmat
%

%
% Edited by:
% 
% Edo Frederix
% The Johns Hopkins University
% Department of Mechanical Engineering
% edofrederix@jhu.edu
%

%
% This file is a modification to the standard createSoapMessage.m file that
% comes with Matlab. The original revision information is left in this
% file.
%
% The element 'points' is stored straight into the DOM as a set of
% characters. The time that this process takes scales linearly with the
% number of points, rather than exponentially.
%

function xmlfile = turbm_createSoapMessage(tns,methodname,values,names,types,style)
%createSoapMessage Create a SOAP message, ready to send to the server.
%   createSoapMessage(NAMESPACE,METHOD,VALUES,NAMES,TYPES,STYLE) creates a SOAP
%   message.  VALUES, NAMES, and TYPES are cell arrays.  NAMES will
%   default to dummy names and TYPES will default to unspecified.  STYLE
%   specifies 'document' or 'rpc' messages ('rpc' is the default).
%
%   Example:
%
%   message = createSoapMessage( ...
%       'urn:xmethods-delayed-quotes', ...
%       'getQuote', ...
%       {'GOOG'}, ...
%       {'symbol'}, ...
%       {'{http://www.w3.org/2001/XMLSchema}string'}, ...
%       'rpc');
%   response = callSoapService( ...
%       'http://64.124.140.30:9090/soap', ...
%       'urn:xmethods-delayed-quotes#getQuote', ...
%       message);
%   price = parseSoapResponse(response)
% 
%   See also createClassFromWsdl, callSoapService, parseSoapResponse.

% Matthew J. Simoneau, June 2003
% $Revision: 1.1.6.8 $  $Date: 2006/06/20 20:11:31 $
% Copyright 1984-2006 The MathWorks, Inc.

% Default to made-up names.
if (nargin < 4)
    names = cell(length(values));
    for i = 1:length(values)
        names{i} = sprintf('param%.0f',i);
    end
end
% Default to empty types.
if (nargin < 5)
    types = cell(length(values));
    types(:) = {''};
end
% Default to 'rpc'.
if (nargin < 6)
    style = 'rpc';
end

%   Form the envelope
dom = com.mathworks.xml.XMLUtils.createDocument('http://schemas.xmlsoap.org/soap/envelope/','soap:Envelope');
rootNode = dom.getDocumentElement;
switch style
    case 'rpc'
        rootNode.setAttribute('xmlns:n',tns);
end
rootNode.setAttribute('xmlns:soap','http://schemas.xmlsoap.org/soap/envelope/');
rootNode.setAttribute('xmlns:soapenc','http://schemas.xmlsoap.org/soap/encoding/');
rootNode.setAttribute('xmlns:xs','http://www.w3.org/2001/XMLSchema');
rootNode.setAttribute('xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance');

% Form the body
soapBody = dom.createElement('soap:Body');
soapBody.setAttribute('soap:encodingStyle','http://schemas.xmlsoap.org/soap/encoding/');

% Method
switch style
    case 'rpc'
        soapMessage = dom.createElement(['n:' methodname]);
    case 'document'
        soapMessage = dom.createElement(methodname);
        soapMessage.setAttribute('xmlns',tns)
end
soapBody.appendChild(soapMessage);

% Add inputs
populate(dom,soapMessage,values,names,types)

% Add the body
rootNode.appendChild(soapBody);

% Add points
[nPoints pointName nItems itemNames valPointer] = getPointsInfo(dom,values,names);

points = struct2cell(values{valPointer}); % Cell of cell of structs of points
points = points{1}; % Cell of structs of points

formatString = '';
for k = 1:nItems
    formatString = strcat(formatString, '<', itemNames{k}, '>%1.8f</', itemNames{k}, '>');
end

formatString = strcat('<%s>', formatString, '</%s>');

output = cell(1, nPoints);
for j = 1:nPoints
    point = struct2cell(points{j});
    output{1, j} = char(sprintf(formatString, pointName, point{:}, pointName));
end

% Let's output plain text, instead of a DOM
xmlfile = regexprep(xmlwrite(dom), '--points--', cell2mat(output));

%===============================================================================
function populate(dom,node,values,names,types)

for i = 1:length(names)
    if ischar(types{i}) && ...
            numel(types{i} > 2) && ...
            strcmp(types{i}(end-1:end),'[]')
        soapArray = dom.createElement(names{i});
        soapArray.setAttribute('xsi:type','soapenc:Array');
        addTypeAttribute(soapArray,'soapenc:arrayType',types{i})
        v = values{i};
        if ~iscell(v)
            v = num2cell(v);
        end
        populate(dom,soapArray, ...
            v,repmat({'item'},size(values{i})), ...
            cell(size(values{i})));
        node.appendChild(soapArray);    
    elseif strcmp(names{i}, 'points')
        % Let's treat this guy differently
        element = dom.createElement(names{i});
        element.appendChild(dom.createTextNode('--points--'));
        node.appendChild(element);
    elseif isstruct(values{i})
        for j = 1:length(values{i})
            soapStruct = dom.createElement(names{i});
            populate(dom,soapStruct, ...
                struct2cell(values{i}(j)),fieldnames(values{i}(j)), ...
                cell(size(fieldnames(values{i}(j)))));
            node.appendChild(soapStruct);
        end
    elseif iscell(values{i})
        populate(dom,node, ...
            values{i},repmat(names(i),size(values{i})), ...
            cell(size(values{i})));
    else
        input = dom.createElement(names{i});
        addTypeAttribute(input,'xsi:type',types{i})
        textToSend = convertToText(values{i});
        input.appendChild(dom.createTextNode(textToSend));
        node.appendChild(input);
    end
end

%===============================================================================
function addTypeAttribute(node,attribute,type)
if ~isempty(type)
    if ~isempty(strmatch('{http://www.w3.org/2001/XMLSchema}',type))
        node.setAttribute(attribute,['xs:' type(35:end)]);
    else
        % TODO: Better type handling.
        %fprintf('Could do better with "%s" in "%s".',types{i},names{i})
    end
end

%===============================================================================
function s = convertToText(x)
switch class(x)
    case 'char'
        s = x;
    otherwise
        s = mat2str(x);
end

%==========================================================================
function [nPoints pointName nItems itemNames i] = getPointsInfo(dom,values,names)
for i = 1:length(names)
    if strcmp(names{i}, 'points')
        points = struct2cell(values{i}); % Cell of cell of structs of points
        points = points{1}; % Cell of structs of points
        nPoints = size(points, 1);
        pointName = char(fieldnames(values{i}));
        itemNames = fieldnames(points{1});
        nItems = length(itemNames);
    end
end