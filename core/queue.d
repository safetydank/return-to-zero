module core.queue;

/**
 *  A generic FIFO queue class
 */
class Queue(T)
{
  int _c_nodes;
  int _i_node;
  uint _c_queueNodes;

  class Node
  {
    public:
      T data;
      Node prev;
      Node next;
      bool b_active;

    public void init(Node prev, Node next, bool b_active)
    {
      this.prev = prev;
      this.next = next;
      this.b_active = b_active;
    }
  }

  Node[] _nodePool;
  Node _head;
  Node _tail;

  public uint length() { return _c_queueNodes; }

  public this(int c_nodes)
  {
    _c_nodes = c_nodes;
    _head = null;
    _tail = null;

    _nodePool = new Node[_c_nodes];
    foreach (inout node; _nodePool)
    {
      node = new Node();
      node.b_active = false;
    }

    _i_node = 0;
    _c_queueNodes = 0;
  }

  private Node getFreeNode()
  {
    for (int i = 0; i < _c_nodes; ++i)
    {
      if (--_i_node < 0)
        _i_node = _c_nodes - 1;

      assert(_nodePool[_i_node] !is null);
      if (!_nodePool[_i_node].b_active)
        return _nodePool[_i_node];
    }

    //  No free nodes in the queue, resize and try again
    _c_nodes *= 2;
    _nodePool.length = _c_nodes;
    for(int i = _c_nodes / 2; i < _c_nodes; ++i)
    {
      _nodePool[i] = new Node();
      _nodePool[i].b_active = false;
    }
    _i_node = 0;

    return getFreeNode();
  }

  invariant
  {
    assert ( (_head is null && _tail is null) 
      || (_head !is null && _tail !is null) );
  }

  public void enqueue(T data)
  {
    Node node = getFreeNode();
    assert(node !is null);

    node.init(null, null, true);
    node.data = data;

    if (_head is null && _tail is null)
    {
      _head = _tail = node;
    }
    else
    {
      _tail.next = node;
      node.prev = _tail;
      node.next = null;
      _tail = node;
    }

    ++_c_queueNodes;
  }

  public T dequeue()
  in
  {
    assert(_c_queueNodes > 0);
  }
  body
  {
    T ret = _head.data;          
    _head.b_active = false;
    _head = _head.next;

    if (_head is null) _tail = null;

    --_c_queueNodes;

    return ret;
  }

  unittest
  {
    const int LENGTH = 100;
    int i;
    Queue!(int) myQueue = new Queue!(int)(LENGTH);

    for (int n = 0; n < 100; ++n)
    {
      for (i = 0; i < LENGTH/4; ++i)
      {
        myQueue.enqueue(i);
        assert(myQueue.length == i + 1);
      }

      for (i = 0; i < LENGTH/4; ++i)
      {
        int v = myQueue.dequeue();
        assert(v == i);
        assert(myQueue.length == LENGTH/4 - (i+1));
      }
    }

    assert(myQueue.length == 0);

    //  Test queue resize
    int newLength = LENGTH * 8;
    for (i = 0; i < newLength; ++i)
    {
      myQueue.enqueue(i);
      assert(myQueue.length == i + 1);
    }
    for (i = 0; i < newLength; ++i)
    {
      int v = myQueue.dequeue();
      assert(v == i);
      assert(myQueue.length == newLength - (i+1));
    }
  }
}
