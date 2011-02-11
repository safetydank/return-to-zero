module de.vertexset;

import core.logger;
import core.util;
import de.vertex;

//  A set of vertex lists
class VertexSet
{
  Vertex[][int] _setArray;

  public void copyVertexList(Vertex[] list, int id, int i = 0, int count = 0)
  {
    if (count == 0) count = list.length;

    // Logger.instance.message(format("Copying vertex list len %d id %d i %d count %d", 
    // list.length, id, i, count));

    _setArray[id] = new Vertex[count];
    memcpy(_setArray[id].ptr, &list[i], count * Vertex.sizeof);
  }

  public void opIndexAssign(Vertex[] list, int id)
  {
    copyVertexList(list, id);
  }

  public Vertex[] opIndex(int id)
  {
    return _setArray[id];
  }
}
