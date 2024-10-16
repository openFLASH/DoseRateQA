%% copyFields
% Copy and overwrite the fields of structure |TO| with the fields contained in |FROM|.
% The |FROM| contains fields missing in |TO|, those will be added to |TO|.
% If structure |TO| contains fields missing in |FROM|, those will be left unchanged in |TO|
%
%% Syntax
% |TO = copyFields(FROM , TO)|
%
%
%% Description
% |TO = copyFields(FROM , TO)| Description
%
%
%% Input arguments
% |FROM| - _STRUCT_ - Structure to be copied in the structure |TO|
%
% |TO| - _STRUCT_ - Structure to receiving the elements from |FROM|
%
%% Output arguments
%
% |TO| - _STRUCT_ - Updated structure. The elements of |FROM| overwtrote those of |TO|.
%
%
%% Contributors
% Authors : R. Labarbe (open.reggui@gmail.com)

function TO = copyFields(FROM , TO)

  if isempty(FROM)
    %We received an empty structure
    TO = [];
    return;
  end

  if isstruct(FROM)
    NAMES = fieldnames(FROM); %Get the list of all the field names
  else
    %FROM is not a structure. Just return it
    TO = FROM;
    return
  end

  for idx = 1:numel(NAMES)
    %Copy each field sequentially
    elemFROM = getfield(FROM,NAMES{idx}); %The element to be copied
    CL = class(elemFROM);

    if isfield(TO,NAMES{idx})
      %The field exists in the destination structure. It will be overwritten

      switch CL
          case 'cell'
            %This is a cell array. Copy each element
            TO = copyArray(elemFROM , TO , NAMES{idx} , 'cell');

          case 'struct'

            if numel(elemFROM ) >1
              %This is an array of structure.
              TO = copyArray(elemFROM , TO , NAMES{idx} , 'struct');

            else
              %This is a structure. Copy it recursively
              DupStruc = copyFields(elemFROM ,  getfield(TO,NAMES{idx}) );
              TO = setfield(TO ,  NAMES{idx} , DupStruc ); %Copy the field from structure |FROM| to structure |TO|
            end

          otherwise
            TO = setfield(TO ,  NAMES{idx} , elemFROM ); %Copy the field from structure |FROM| to structure |TO|

      end %switch CL

  else
    %The field does not exist in the destination structure. We will create a new field
    TO = setfield(TO ,  NAMES{idx} , elemFROM );

  end %if isfield(TO,NAMES{idx})

 end %for idx

end


%=======================
%Copy sequentialmly each element of the array
%
% INPUT
% elemFROM -_ARRAY_- Element to be copied
% TO -_STRUCTURE_- Structure where to copy the array
% NAME -_STRING_- Name of the field in which to copy the array
% arrayType -_STRING_- Type of array : 'cell' or 'struct'
%=======================

function TO = copyArray(elemFROM , TO , NAME , arrayType)
    %This is a cell array. Copy each element
    elemTO = getfield(TO,NAME);
    Scell = size(elemTO ); %size of the cell element %TODO this assumes that the destination cell array is larger than the FROM cell array

    %Copy each element of the cell array sucessively
    for idxCell = 1:numel(elemFROM)

      switch arrayType
      case 'cell'
          DupStruc = copyFields(elemFROM{idxCell} , elemTO{idxCell});
          TO = setfield(TO ,  NAME , {idxCell} , {DupStruc} ); %Copy the field from structure |FROM| to structure |TO|. Use a linear index for the cell matrix
      case 'struct'
          DupStruc = copyFields(elemFROM(idxCell) , elemTO(idxCell));
          TO = setfield(TO ,  NAME , {idxCell} , DupStruc ); %Copy the field from structure |FROM| to structure |TO|
      end
    end

    TO = setfield(TO ,  NAME , reshape(getfield(TO ,  NAME) ,   Scell ) ); %REshape the field to the original size

  end
